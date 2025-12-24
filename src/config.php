<?php
$currency = '₹';
$db_username = getenv('DB_USER');
$db_password = getenv('DB_PASSWORD');
$db_name     = getenv('DB_NAME');
$db_host     = getenv('DB_HOST');

$mysqli = new mysqli($db_host, $db_username, $db_password,$db_name);
?>
