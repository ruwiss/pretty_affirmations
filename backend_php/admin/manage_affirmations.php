<?php
require_once 'auth_check.php';
require_once '../config/Database.php';

$database = new Database();
$db = $database->getConnection();

// Kategorileri al
$query = "SELECT c.id, c.category_key, ct.name as category_name
          FROM categories c
          LEFT JOIN category_translations ct ON c.id = ct.category_id
          WHERE ct.language_code = 'tr_TR'
          ORDER BY c.id DESC";
$stmt = $db->prepare($query);
$stmt->execute();
$categories = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Seçili kategoriyi al
$selected_category = isset($_GET['category']) ? $_GET['category'] : null;

// Seçili dili al
$selected_language = isset($_GET['language']) ? $_GET['language'] : 'all';

// Affirmation ekleme işlemi
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action'])) {
    if ($_POST['action'] === 'add') {
        $category_id = $_POST['category_id'];
        $language = $_POST['language'];
        $content = $_POST['content'];

        if ($selected_category && $category_id != $selected_category) {
            $error_message = "Lütfen seçili kategori için olumlama ekleyin.";
        } else {
            try {
                // Sadece seçili dil için ekleme yap
                $query = "INSERT INTO affirmations (category_id, language_code, content) VALUES (?, ?, ?)";
                $stmt = $db->prepare($query);
                $stmt->execute([$category_id, $language, $content]);
                $success_message = "Affirmation başarıyla eklendi!";
            } catch(PDOException $e) {
                $error_message = "Hata oluştu: " . $e->getMessage();
            }
        }
    } elseif ($_POST['action'] === 'delete') {
        $affirmation_id = $_POST['affirmation_id'];

        if ($selected_category) {
            $query = "DELETE FROM affirmations WHERE id = ? AND category_id = ?";
            $stmt = $db->prepare($query);
            $stmt->execute([$affirmation_id, $selected_category]);
        } else {
            $query = "DELETE FROM affirmations WHERE id = ?";
            $stmt = $db->prepare($query);
            $stmt->execute([$affirmation_id]);
        }

        try {
            $stmt->execute();
            $success_message = "Olumlama başarıyla silindi!";
        } catch(PDOException $e) {
            $error_message = "Hata oluştu: " . $e->getMessage();
        }
    }
}

// Affirmation listesini al
$where_conditions = [];
$params = [];

if ($selected_category) {
    $where_conditions[] = "a.category_id = :category_id";
    $params[':category_id'] = $selected_category;
}

if ($selected_language !== 'all') {
    $where_conditions[] = "a.language_code = :language";
    $params[':language'] = $selected_language;
}

$where_clause = !empty($where_conditions) ? "WHERE " . implode(" AND ", $where_conditions) : "";

// Pagination için değişkenler
$records_per_page = 10; // Sayfa başına gösterilecek kayıt sayısı
$current_page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
$offset = ($current_page - 1) * $records_per_page;

// Toplam kayıt sayısını al
$count_query = "SELECT COUNT(*) as total FROM affirmations a $where_clause";
$count_stmt = $db->prepare($count_query);
foreach ($params as $key => $value) {
    $count_stmt->bindValue($key, $value);
}
$count_stmt->execute();
$total_count = $count_stmt->fetch(PDO::FETCH_ASSOC)['total'];

// Toplam sayfa sayısını hesapla
$total_pages = ceil($total_count / $records_per_page);

// Ana sorguya LIMIT ve OFFSET ekle
$query = "SELECT a.*, c.category_key as category_name
          FROM affirmations a
          LEFT JOIN categories c ON a.category_id = c.id
          $where_clause
          ORDER BY a.id DESC
          LIMIT $records_per_page OFFSET $offset";

$stmt = $db->prepare($query);
foreach ($params as $key => $value) {
    $stmt->bindValue($key, $value);
}
$stmt->execute();
$affirmations = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Olumlamalar</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body class="pattern-bg">
    <div class="container mx-auto px-4 py-8">
        <div class="flex justify-between items-center mb-8">
            <h1 class="text-2xl font-bold text-gray-800">Olumlamalar</h1>
        </div>

        <?php if (isset($error_message)): ?>
            <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-4" role="alert">
                <span class="block sm:inline"><?php echo $error_message; ?></span>
            </div>
        <?php endif; ?>

        <?php if (isset($success_message)): ?>
            <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative mb-4" role="alert">
                <span class="block sm:inline"><?php echo $success_message; ?></span>
            </div>
        <?php endif; ?>

        <!-- Olumlama Ekleme Formu -->
        <div class="bg-white rounded-lg shadow-md p-6 mb-8">
            <h2 class="text-xl font-semibold text-gray-800 mb-4">Yeni Olumlama Ekle</h2>
            <form method="POST" class="space-y-6">
                <input type="hidden" name="action" value="add">

                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Kategori</label>
                        <select name="category_id" required class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                            <?php foreach ($categories as $category): ?>
                                <option value="<?php echo $category['id']; ?>" <?php echo ($selected_category == $category['id']) ? 'selected' : ''; ?>>
                                    <?php echo $category['category_name']; ?>
                                </option>
                            <?php endforeach; ?>
                        </select>
                    </div>

                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Dil</label>
                        <select name="language" required class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                            <option value="tr_TR" <?php echo $selected_language === 'tr_TR' ? 'selected' : ''; ?>>Türkçe</option>
                            <option value="en" <?php echo $selected_language === 'en' ? 'selected' : ''; ?>>English</option>
                            <option value="ru" <?php echo $selected_language === 'ru' ? 'selected' : ''; ?>>Русский</option>
                            <option value="zh" <?php echo $selected_language === 'zh' ? 'selected' : ''; ?>>中文</option>
                        </select>
                    </div>
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">İçerik</label>
                    <textarea name="content" required rows="3" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"></textarea>
                </div>

                <div class="flex justify-end">
                    <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500">
                        Ekle
                    </button>
                </div>
            </form>
        </div>
        <!-- Olumlamalar Listesi -->
        <div class="bg-white rounded-lg shadow-md p-6">
            <div class="flex flex-col md:flex-row justify-between items-start md:items-center mb-6 space-y-4 md:space-y-0">
                <h2 class="text-xl font-semibold text-gray-800">Mevcut Olumlamalar (Toplam: <?php echo $total_count; ?>)</h2>

                <!-- Filtreler -->
                <form method="GET" action="" class="flex flex-col sm:flex-row items-start sm:items-center space-y-2 sm:space-y-0 sm:space-x-4 w-full md:w-auto">
                    <select name="category" onchange="this.form.submit()" class="w-full sm:w-auto px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                        <option value="">Tüm Kategoriler</option>
                        <?php foreach ($categories as $category): ?>
                            <option value="<?php echo $category['id']; ?>" <?php echo ($selected_category == $category['id']) ? 'selected' : ''; ?>>
                                <?php echo $category['category_name']; ?>
                            </option>
                        <?php endforeach; ?>
                    </select>

                    <select name="language" onchange="this.form.submit()" class="w-full sm:w-auto px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                        <option value="all" <?php echo $selected_language === 'all' ? 'selected' : ''; ?>>Tüm Diller</option>
                        <option value="tr_TR" <?php echo $selected_language === 'tr_TR' ? 'selected' : ''; ?>>Türkçe</option>
                        <option value="en" <?php echo $selected_language === 'en' ? 'selected' : ''; ?>>English</option>
                        <option value="ru" <?php echo $selected_language === 'ru' ? 'selected' : ''; ?>>Русский</option>
                        <option value="zh" <?php echo $selected_language === 'zh' ? 'selected' : ''; ?>>中文</option>
                    </select>
                </form>
            </div>

            <div class="overflow-x-auto">
                <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-gray-50">
                        <tr>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Kategori</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Dil</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">İçerik</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Oluşturulma Tarihi</th>
                            <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">İşlemler</th>
                        </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200">
                        <?php foreach ($affirmations as $affirmation): ?>
                            <tr class="hover:bg-gray-50">
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900"><?php echo $affirmation['id']; ?></td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900"><?php echo $affirmation['category_name']; ?></td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                                    <?php
                                        $langInfo = getLanguageInfo($affirmation['language_code']);
                                        echo $langInfo['flag'] . ' ' . $langInfo['name'];
                                    ?>
                                </td>
                                <td class="px-6 py-4 text-sm text-gray-900"><?php echo $affirmation['content']; ?></td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                                    <?php echo date('d.m.Y H:i', strtotime($affirmation['created_at'])); ?>
                                </td>
                                <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                                    <form method="POST" class="inline-block" onsubmit="return confirm('Bu olumlamayı silmek istediğinizden emin misiniz?');">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="affirmation_id" value="<?php echo $affirmation['id']; ?>">
                                        <button type="submit" class="text-red-600 hover:text-red-900">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </form>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <?php
    // Dil bayrakları ve isimleri için yardımcı fonksiyon
    function getLanguageInfo($code) {
        $languages = [
            'tr_TR' => ['flag' => '<img src="../assets/flags/TR.svg" class="inline-block w-6 h-4 mr-2" alt="TR">', 'name' => 'Türkçe'],
            'en' => ['flag' => '<img src="../assets/flags/GB.svg" class="inline-block w-6 h-4 mr-2" alt="EN">', 'name' => 'İngilizce'],
            'ru' => ['flag' => '<img src="../assets/flags/RU.svg" class="inline-block w-6 h-4 mr-2" alt="RU">', 'name' => 'Rusça'],
            'zh' => ['flag' => '<img src="../assets/flags/CN.svg" class="inline-block w-6 h-4 mr-2" alt="ZH">', 'name' => 'Çince']
        ];
        return $languages[$code] ?? ['flag' => '<img src="../assets/flags/blank.svg" class="inline-block w-6 h-4 mr-2" alt="?">', 'name' => $code];
    }
    ?>

    <!-- Pagination -->
    <div class="mt-12 mb-8 flex flex-col items-center space-y-4">
        <!-- Sayfa bilgisi -->
        <div class="text-sm text-gray-700">
            <span>Toplam <?php echo $total_count; ?> kayıttan </span>
            <span class="font-medium"><?php echo ($offset + 1); ?></span>
            <span> - </span>
            <span class="font-medium"><?php echo min($offset + $records_per_page, $total_count); ?></span>
            <span> arası gösteriliyor</span>
        </div>

        <!-- Sayfa numaraları -->
        <nav class="relative z-0 inline-flex rounded-md shadow-lg -space-x-px" aria-label="Pagination">
            <?php if ($current_page > 1): ?>
                <a href="?page=<?php echo ($current_page - 1); ?>&category=<?php echo $selected_category; ?>&language=<?php echo $selected_language; ?>"
                   class="relative inline-flex items-center px-3 py-2 rounded-l-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50 hover:text-blue-600 transition-colors duration-200">
                    <i class="fas fa-chevron-left mr-1"></i>
                    Önceki
                </a>
            <?php endif; ?>

            <?php
            // Toplam sayfa sayısı 7'den fazlaysa, sayfa numaralarını kısalt
            $start = max(1, min($current_page - 2, $total_pages - 4));
            $end = min($total_pages, max($current_page + 2, 5));

            // İlk sayfa
            if ($start > 1) {
                echo "<a href='?page=1&category=$selected_category&language=$selected_language'
                        class='relative inline-flex items-center px-4 py-2 border border-gray-300 bg-white text-sm font-medium text-gray-700 hover:bg-gray-50 hover:text-blue-600 transition-colors duration-200'>1</a>";
                if ($start > 2) {
                    echo "<span class='relative inline-flex items-center px-4 py-2 border border-gray-300 bg-white text-sm font-medium text-gray-700'>...</span>";
                }
            }

            // Sayfa numaralarını göster
            for ($i = $start; $i <= $end; $i++) {
                if ($i == $current_page) {
                    echo "<span class='relative inline-flex items-center px-4 py-2 border border-blue-500 bg-blue-50 text-sm font-medium text-blue-600 z-10'>$i</span>";
                } else {
                    echo "<a href='?page=$i&category=$selected_category&language=$selected_language'
                            class='relative inline-flex items-center px-4 py-2 border border-gray-300 bg-white text-sm font-medium text-gray-700 hover:bg-gray-50 hover:text-blue-600 transition-colors duration-200'>$i</a>";
                }
            }

            // Son sayfa
            if ($end < $total_pages) {
                if ($end < $total_pages - 1) {
                    echo "<span class='relative inline-flex items-center px-4 py-2 border border-gray-300 bg-white text-sm font-medium text-gray-700'>...</span>";
                }
                echo "<a href='?page=$total_pages&category=$selected_category&language=$selected_language'
                        class='relative inline-flex items-center px-4 py-2 border border-gray-300 bg-white text-sm font-medium text-gray-700 hover:bg-gray-50 hover:text-blue-600 transition-colors duration-200'>$total_pages</a>";
            }
            ?>

            <?php if ($current_page < $total_pages): ?>
                <a href="?page=<?php echo ($current_page + 1); ?>&category=<?php echo $selected_category; ?>&language=<?php echo $selected_language; ?>"
                   class="relative inline-flex items-center px-3 py-2 rounded-r-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50 hover:text-blue-600 transition-colors duration-200">
                    Sonraki
                    <i class="fas fa-chevron-right ml-1"></i>
                </a>
            <?php endif; ?>
        </nav>
    </div>
</body>
</html>
