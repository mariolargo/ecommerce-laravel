<?php
$host = 'db-laravel.c5eo26ysg0xx.us-east-2.rds.amazonaws.com'; // or localhost
$db   = 'db-laravel';
$user = 'admin';
$pass = 'FGZXWZDSHuiSN8n';
$port = '3306';

$dsn = "mysql:host=$host;port=$port;dbname=$db;charset=utf8mb4";

try {
    $pdo = new PDO($dsn, $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "SUCCESS: PHP-FPM can connect to the database.\n";
} catch (\PDOException $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
}
?>
