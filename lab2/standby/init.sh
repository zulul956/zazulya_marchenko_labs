# Ждем, пока primary будет готова
until pg_isready -h my_primary -p 5432 -U postgres; do
  sleep 1
done

# Очищаем данные в контейнере standby
rm -rf /var/lib/postgresql/data/*

# Делаем резервную копию данных с primary
PGPASSWORD=postgres pg_basebackup -h my_primary -D /var/lib/postgresql/data -U postgres -Fp -Xs -P -R

# Конфигурируем соединение с primary
echo "primary_conninfo = 'host=my_primary port=5432 user=postgres password=postgres'" >> /var/lib/postgresql/data/postgresql.auto.conf

# Исправляем права доступа на данные
chown -R postgres:postgres /var/lib/postgresql/data
chmod 700 /var/lib/postgresql/data

# Запускаем PostgreSQL с нужной конфигурацией
su postgres -c 'postgres -c config_file=/etc/postgresql/postgresql.conf -c hba_file=/etc/postgresql/pg_hba.conf'
