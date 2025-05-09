<?php
session_start();
require_once '../config/Database.php';

// Eğer zaten giriş yapılmışsa panel sayfasına yönlendir
if(isset($_SESSION['admin_logged_in']) && $_SESSION['admin_logged_in'] === true) {
    header("Location: panel.php");
    exit();
}

// Login işlemi
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $password = $_POST['password'] ?? '';
    $recaptcha_response = $_POST['g-recaptcha-response'] ?? '';

    // Localhost kontrolü
    $is_localhost = ($_SERVER['SERVER_NAME'] === 'localhost' || $_SERVER['SERVER_NAME'] === '127.0.0.1');

    // reCAPTCHA doğrulama (sadece localhost değilse)
    $captcha_valid = true; // Varsayılan olarak true (localhost için)

    if (!$is_localhost) {
        $recaptcha_secret = "ENTER_YOUR_SECRET_KEY";
        $verify_response = file_get_contents('https://www.google.com/recaptcha/api/siteverify?secret='.$recaptcha_secret.'&response='.$recaptcha_response);
        $response_data = json_decode($verify_response);
        $captcha_valid = $response_data->success;
    }

    if (!$captcha_valid) {
        $error = "Lütfen robot olmadığınızı doğrulayın!";
    } else {
        // Veritabanı bağlantısı
        $database = new Database();
        $db = $database->getConnection();

        try {
            // Şifreyi veritabanından al
            $query = "SELECT setting_value FROM app_settings WHERE setting_key = 'panel_password'";
            $stmt = $db->prepare($query);
            $stmt->execute();

            if ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                $stored_password = $row['setting_value'];

                if ($password === $stored_password) {
                    $_SESSION['admin_logged_in'] = true;

                    // Set cookie for 30 days
                    $cookie_name = "admin_auth";
                    $cookie_value = password_hash($stored_password, PASSWORD_DEFAULT);
                    setcookie($cookie_name, $cookie_value, time() + (86400 * 30), "/", "", true, true);

                    header("Location: panel.php");
                    exit();
                } else {
                    $error = "Geçersiz şifre!";
                }
            } else {
                $error = "Sistem hatası: Şifre ayarı bulunamadı!";
            }
        } catch(PDOException $e) {
            $error = "Veritabanı hatası!";
        }
    }
}
?>
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Girişi</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <?php if ($_SERVER['SERVER_NAME'] !== 'localhost' && $_SERVER['SERVER_NAME'] !== '127.0.0.1'): ?>
        <script src="https://www.google.com/recaptcha/api.js" async defer></script>
    <?php endif; ?>
</head>
<body class="bg-gray-100 min-h-screen flex items-center justify-center p-4">
    <div class="bg-white p-8 rounded-lg shadow-md w-full max-w-md">
        <h1 class="text-2xl font-semibold text-gray-800 text-center mb-8">Admin Girişi</h1>
        <?php if (isset($error)): ?>
            <div class="text-red-500 text-center mb-4"><?php echo $error; ?></div>
        <?php endif; ?>
        <form method="POST" action="" class="space-y-6">
            <div>
                <input type="password"
                       name="password"
                       placeholder="Şifre"
                       required
                       class="w-full px-4 py-3 rounded-md border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition">
            </div>
            <?php if ($_SERVER['SERVER_NAME'] !== 'localhost' && $_SERVER['SERVER_NAME'] !== '127.0.0.1'): ?>
                <div class="flex justify-center">
                    <div class="g-recaptcha" data-sitekey="6LeRwX4qAAAAAIflfdR3O9hDgUfP6rGkG1ULS3YX"></div>
                </div>
            <?php endif; ?>
            <button type="submit"
                    class="w-full bg-green-500 text-white py-3 px-4 rounded-md hover:bg-green-600 focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2 transition-colors">
                Giriş Yap
            </button>
        </form>
    </div>
</body>
</html>
