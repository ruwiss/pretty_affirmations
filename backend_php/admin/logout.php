<?php
session_start();

// Session'ı temizle
session_unset();
session_destroy();

// Login sayfasına yönlendir
header("Location: login.php");
exit();
?>
