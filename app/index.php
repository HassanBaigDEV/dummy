<?php
include 'db.php';

$query = $pdo->query("SELECT * FROM users");
echo "<h1>User List</h1><ul>";
while ($row = $query->fetch()) {
    echo "<li>{$row['name']} ({$row['email']})</li>";
}
echo "</ul>";
?>
