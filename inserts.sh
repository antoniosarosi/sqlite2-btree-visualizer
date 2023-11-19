echo "BEGIN TRANSACTION;"

for i in {10000..1}; do
    echo "INSERT INTO users (id, name) VALUES ($i, 'User Name $i');"
done

echo "COMMIT;"
