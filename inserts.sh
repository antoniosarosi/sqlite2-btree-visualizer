echo "BEGIN TRANSACTION;"

for i in {1..10000}; do
    echo "INSERT INTO users (id, name) VALUES ($i, 'User Name $i');"
done

echo "COMMIT;"
