<?php
// Hata raporlama ayarları
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require_once 'auth_check.php';
require_once '../config/Database.php';
require_once '../models/DailyEntry.php';

// Veritabanı bağlantısı
$database = new Database();
$db = $database->getConnection();

// Reklam durumunu al
$query = "SELECT setting_value FROM app_settings WHERE setting_key = 'ads_enabled'";
$stmt = $db->prepare($query);
$stmt->execute();
$ads_enabled = $stmt->fetchColumn();

// Satın alma sayısını al
$query = "SELECT COUNT(id) as purchase_count FROM purchases";
$stmt = $db->prepare($query);
$stmt->execute();
$purchase_count = $stmt->fetchColumn();

// Günlük giriş sayılarını al
$dailyEntry = new DailyEntry($db);
$languages = ['en', 'ru', 'tr_TR', 'zh'];
$daily_counts = [];
foreach ($languages as $lang) {
    $daily_counts[$lang] = $dailyEntry->getDailyCount($lang);
}
$total_daily_count = array_sum($daily_counts);
?>
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pretty Affirmations</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        body {
            padding: 0;
            margin: 0;
            background: transparent;
        }
        .content-frame {
            width: 100%;
            height: calc(100vh - 4rem);
            border: none;
        }
        .pattern-bg {
            background-color: #f8fafc;
            background-image: url("../assets/patterns/background.svg");
        }
    </style>
</head>
<body class="pattern-bg">
    <!-- Top Navigation Bar -->
    <nav class="fixed top-0 left-0 right-0 bg-white border-b border-gray-200 z-30">
        <div class="max-w-full mx-auto px-4">
            <div class="flex justify-between h-16">
                <div class="flex items-center justify-center">
                    <!-- Mobile menu button -->
                    <button id="mobile-menu-button" class="lg:hidden inline-flex items-center justify-center p-2 rounded-md text-gray-600 hover:text-gray-900 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-blue-500">
                        <i class="fas fa-bars"></i>
                    </button>
                    <img src="../assets/logo.svg" alt="Pretty Affirmations Logo" class="h-5 w-auto mx-3">
                    <span class="text-xl font-semibold text-gray-800 lg:ml-0">Pretty Affirmations</span>
                </div>

                <!-- Right side buttons -->
                <div class="flex items-center space-x-4">
                    <a href="logout.php" class="inline-flex items-center gap-2 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors">
                        <i class="fas fa-sign-out-alt"></i>
                    </a>
                </div>
            </div>
        </div>
    </nav>

    <!-- Sidebar -->
    <aside id="sidebar" class="fixed inset-y-0 left-0 w-64 bg-white shadow-lg transform -translate-x-full lg:translate-x-0 transition-transform duration-200 ease-in-out z-20">
        <nav class="h-full flex flex-col">
            <div class="px-4 py-5">
                <h2 class="text-xl font-semibold text-gray-800">Pretty Affirmations</h2>
            </div>

            <ul class="flex-1 py-4">
                <li>
                    <a href="manage_affirmations.php" data-page="affirmations" class="menu-item flex items-center px-4 py-3 text-gray-700 hover:bg-gray-100 hover:text-gray-900" target="content-frame">
                        <i class="fas fa-comment-dots w-6"></i>
                        <span>Olumlamalar</span>
                    </a>
                </li>
                <li>
                    <a href="manage_stories.php" data-page="stories" class="menu-item flex items-center px-4 py-3 text-gray-700 hover:bg-gray-100 hover:text-gray-900" target="content-frame">
                        <i class="fas fa-book w-6"></i>
                        <span>Hikayeler</span>
                    </a>
                </li>
                <li>
                    <a href="manage_categories.php" data-page="categories" class="menu-item flex items-center px-4 py-3 text-gray-700 hover:bg-gray-100 hover:text-gray-900" target="content-frame">
                        <i class="fas fa-tags w-6"></i>
                        <span>Kategoriler</span>
                    </a>
                </li>

                <li>
                    <a href="ai_page.php" data-page="ai" class="menu-item flex items-center px-4 py-3 text-gray-700 hover:bg-gray-100 hover:text-gray-900" target="content-frame">
                        <i class="fas fa-robot w-6"></i>
                        <span>Yapay Zeka</span>
                    </a>
                </li>
                <li>
                    <a href="api_documentation.php" data-page="api" class="menu-item flex items-center px-4 py-3 text-gray-700 hover:bg-gray-100 hover:text-gray-900" target="content-frame">
                        <i class="fas fa-code w-6"></i>
                        <span>API Dökümantasyonu</span>
                    </a>
                </li>
                <li>
                    <a href="manage_settings.php" data-page="settings" class="menu-item flex items-center px-4 py-3 text-gray-700 hover:bg-gray-100 hover:text-gray-900" target="content-frame">
                        <i class="fas fa-cog w-6"></i>
                        <span>Ayarlar</span>
                    </a>
                </li>
            </ul>

            <!-- İstatistik Bilgileri -->
            <div class="mt-auto border-t border-gray-200 pt-4 px-4 mb-4">
                <div class="flex items-center py-2 text-sm">
                    <i class="fas fa-ad w-6"></i>
                    <span>Reklamlar:
                        <?php if ($ads_enabled == 'true' || $ads_enabled == 1): ?>
                            <span class="text-green-600 font-medium">Aktif</span>
                        <?php else: ?>
                            <span class="text-red-600 font-medium">Pasif</span>
                        <?php endif; ?>
                    </span>
                </div>
                <div class="flex items-center py-2 text-sm">
                    <i class="fas fa-shopping-cart w-6"></i>
                    <span>Satın Alma: <span class="font-medium"><?php echo number_format($purchase_count); ?></span></span>
                </div>
                <div class="flex items-center py-2 text-sm group relative">
                    <i class="fas fa-chart-line w-6"></i>
                    <span>Bugünkü Girişler: <span class="font-medium"><?php echo number_format($total_daily_count); ?></span></span>

                    <!-- Tooltip -->
                    <div class="hidden group-hover:block absolute left-0 bottom-full mb-2 w-48 bg-gray-800 text-white text-xs rounded-lg p-2 shadow-lg">
                        <div class="space-y-1">
                            <?php foreach ($languages as $lang): ?>
                                <div class="flex justify-between">
                                    <span><?php echo $lang; ?>:</span>
                                    <span class="font-medium"><?php echo number_format($daily_counts[$lang]); ?></span>
                                </div>
                            <?php endforeach; ?>
                        </div>
                        <!-- Tooltip arrow -->
                        <div class="absolute left-4 bottom-0 transform translate-y-1/2 rotate-45 w-2 h-2 bg-gray-800"></div>
                    </div>
                </div>
            </div>
        </nav>
    </aside>

    <!-- Main Content -->
    <main class="lg:ml-64 pt-16">
        <iframe id="content-frame" name="content-frame" class="content-frame"></iframe>
    </main>
<script>
    document.addEventListener('DOMContentLoaded', () => {
        document.getElementById('content-frame').src = 'manage_affirmations.php';
    });

    const mobileMenuButton = document.getElementById('mobile-menu-button');
    const sidebar = document.getElementById('sidebar');
    let isMenuOpen = false;

    function toggleMenu(open) {
        if (window.innerWidth < 1024) {
            if (open) {
                sidebar.classList.remove('-translate-x-full');
                sidebar.classList.add('translate-x-0');
            } else {
                sidebar.classList.add('-translate-x-full');
                sidebar.classList.remove('translate-x-0');
            }
            isMenuOpen = open;
        }
    }

    mobileMenuButton.addEventListener('click', (e) => {
        e.stopPropagation();
        toggleMenu(!isMenuOpen);
    });

    sidebar.addEventListener('click', (e) => {
        if (e.target.closest('.menu-item') && window.innerWidth < 1024) {
            toggleMenu(false);
        }
    });
</script>
</body>
</html>
