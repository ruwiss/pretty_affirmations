<?php

require_once 'auth_check.php';
require_once '../config/Database.php';

try {
    $database = new Database();
    $db = $database->getConnection();

    if (!$db) {
        throw new Exception("Veritabanı bağlantısı kurulamadı");
    }
} catch (Exception $e) {
    die("Hata: " . $e->getMessage());
}

// Kategori ekleme işlemi
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action'])) {
    if ($_POST['action'] === 'add') {
        try {
            $category_key = $_POST['category_key'];
            $image_url = '';

            // Resim yükleme işlemi
            if (isset($_FILES['category_image']) && $_FILES['category_image']['error'] === UPLOAD_ERR_OK) {
                $file = $_FILES['category_image'];
                $fileName = time() . '_' . preg_replace('/[^a-zA-Z0-9.]/', '_', $file['name']);
                $uploadDir = '../assets/category/';
                $uploadPath = $uploadDir . $fileName;

                error_log("Yüklenen dosya: " . $fileName);


                // Klasör kontrolü ve oluşturma
                if (!file_exists($uploadDir)) {
                    if (!mkdir($uploadDir, 0777, true)) {
                        throw new Exception("Klasör oluşturulamadı. Klasör yolu: " . $uploadDir);
                    }
                }

                // Klasör yazma izni kontrolü
                if (!is_writable($uploadDir)) {
                    throw new Exception("Klasöre yazma izni yok. Klasör: " . $uploadDir . " Mevcut izinler: " . substr(sprintf('%o', fileperms($uploadDir)), -4));
                }

                // Resim türü kontrolü
                $allowedTypes = ['image/jpeg', 'image/png', 'image/gif'];
                if (!in_array($file['type'], $allowedTypes)) {
                    throw new Exception("Sadece JPG, PNG ve GIF formatları desteklenir. Yüklenen dosya türü: " . $file['type']);
                }

                try {
                    // Resmi yükle
                    if (!move_uploaded_file($file['tmp_name'], $uploadPath)) {
                        $uploadError = error_get_last();
                        error_log("Failed to move uploaded file: " . print_r($uploadError, true));
                        throw new Exception("Dosya yüklenemedi. Hata: " . $uploadError['message']);
                    }
                } catch (Exception $e) {
                    error_log("Image upload error: " . $e->getMessage());
                    die("Hata: " . $e->getMessage());
                }

                $image_url = 'assets/category/' . $fileName;

                // Dosya izinlerini ayarla
                chmod($uploadPath, 0644);
            }

            if (!isset($error_message)) {
                // Önce categories tablosuna ekle
                $query = "INSERT INTO categories (category_key, image_url) VALUES (?, ?)";
                $stmt = $db->prepare($query);

                try {
                    $db->beginTransaction();

                    $stmt->execute([$category_key, $image_url]);
                    $category_id = $db->lastInsertId();

                    // Şimdi tüm diller için çevirileri ekle
                    $languages = ['tr_TR', 'en', 'ru', 'zh'];
                    foreach ($languages as $lang) {
                        $name = $_POST['name_' . $lang];
                        $query = "INSERT INTO category_translations (category_id, language_code, name) VALUES (?, ?, ?)";
                        $stmt = $db->prepare($query);
                        $stmt->execute([$category_id, $lang, $name]);
                    }

                    $db->commit();
                    $success_message = "Kategori başarıyla eklendi!";
                } catch(PDOException $e) {
                    $db->rollBack();
                    error_log("Hata oluştu: " . $e->getMessage() . "\n" . $e->getTraceAsString());
                    $error_message = "Hata oluştu: " . $e->getMessage();
                    // Resim yüklendiyse sil
                    if ($image_url && file_exists('../' . $image_url)) {
                        unlink('../' . $image_url);
                    }
                }
            }
        } catch (Exception $e) {
            error_log("Hata oluştu: " . $e->getMessage() . "\n" . $e->getTraceAsString());
            die("İşlem sırasında hata oluştu: " . $e->getMessage());
        }
    } elseif ($_POST['action'] === 'edit') {
        try {
            $category_id = $_POST['category_id'];
            $category_key = $_POST['category_key'];
            $old_image = $_POST['old_image'];
            $image_url = $old_image; // Varsayılan olarak eski resmi kullan

            // Resim yükleme işlemi - sadece yeni resim seçildiyse
            if (isset($_FILES['category_image']) && $_FILES['category_image']['error'] === UPLOAD_ERR_OK && $_FILES['category_image']['size'] > 0) {
                $file = $_FILES['category_image'];
                $fileName = time() . '_' . preg_replace('/[^a-zA-Z0-9.]/', '_', $file['name']);
                $uploadDir = '../assets/category/';
                $uploadPath = $uploadDir . $fileName;

                // Klasör kontrolü ve oluşturma
                if (!file_exists($uploadDir)) {
                    if (!mkdir($uploadDir, 0777, true)) {
                        throw new Exception("Klasör oluşturulamadı. Klasör yolu: " . $uploadDir);
                    }
                }

                // Klasör yazma izni kontrolü
                if (!is_writable($uploadDir)) {
                    throw new Exception("Klasöre yazma izni yok. Klasör: " . $uploadDir . " Mevcut izinler: " . substr(sprintf('%o', fileperms($uploadDir)), -4));
                }

                // Resim türü kontrolü
                $allowedTypes = ['image/jpeg', 'image/png', 'image/gif'];
                if (!in_array($file['type'], $allowedTypes)) {
                    throw new Exception("Sadece JPG, PNG ve GIF formatları desteklenir. Yüklenen dosya türü: " . $file['type']);
                }

                try {
                    // Resmi yükle
                    if (!move_uploaded_file($file['tmp_name'], $uploadPath)) {
                        $uploadError = error_get_last();
                        error_log("Failed to move uploaded file: " . print_r($uploadError, true));
                        throw new Exception("Dosya yüklenemedi. Hata: " . $uploadError['message']);
                    }
                } catch (Exception $e) {
                    error_log("Image upload error: " . $e->getMessage());
                    die("Hata: " . $e->getMessage());
                }

                $image_url = 'assets/category/' . $fileName;
                // Eski resmi sil
                if ($old_image && file_exists('../' . $old_image)) {
                    unlink('../' . $old_image);
                }

                // Dosya izinlerini ayarla
                chmod($uploadPath, 0644);
            }

            if (!isset($error_message)) {
                try {
                    $db->beginTransaction();

                    // Kategori anahtarını güncelle
                    $query = "UPDATE categories SET category_key = ?, image_url = ? WHERE id = ?";
                    $stmt = $db->prepare($query);
                    $stmt->execute([$category_key, $image_url, $category_id]);

                    // Çevirileri güncelle
                    $languages = ['tr_TR', 'en', 'ru', 'zh'];
                    foreach ($languages as $lang) {
                        $name = $_POST['name_' . $lang];
                        $query = "UPDATE category_translations SET name = ? WHERE category_id = ? AND language_code = ?";
                        $stmt = $db->prepare($query);
                        $stmt->execute([$name, $category_id, $lang]);
                    }

                    $db->commit();
                    $success_message = "Kategori başarıyla güncellendi!";
                } catch(PDOException $e) {
                    $db->rollBack();
                    error_log("Hata oluştu: " . $e->getMessage() . "\n" . $e->getTraceAsString());
                    $error_message = "Hata oluştu: " . $e->getMessage();
                }
            }
        } catch (Exception $e) {
            error_log("Hata oluştu: " . $e->getMessage() . "\n" . $e->getTraceAsString());
            die("İşlem sırasında hata oluştu: " . $e->getMessage());
        }
    } elseif ($_POST['action'] === 'delete') {
        try {
            $category_id = $_POST['category_id'];

            try {
                $db->beginTransaction();

                // Önce çevirileri sil
                $query = "DELETE FROM category_translations WHERE category_id = ?";
                $stmt = $db->prepare($query);
                $stmt->execute([$category_id]);

                // Sonra kategoriyi sil
                $query = "DELETE FROM categories WHERE id = ?";
                $stmt = $db->prepare($query);
                $stmt->execute([$category_id]);

                $db->commit();
                $success_message = "Kategori başarıyla silindi!";
            } catch(PDOException $e) {
                $db->rollBack();
                error_log("Hata oluştu: " . $e->getMessage() . "\n" . $e->getTraceAsString());
                $error_message = "Hata oluştu: " . $e->getMessage();
            }
        } catch (Exception $e) {
            error_log("Hata oluştu: " . $e->getMessage() . "\n" . $e->getTraceAsString());
            die("İşlem sırasında hata oluştu: " . $e->getMessage());
        }
    }
}

// Mevcut kategorileri ve çevirilerini listele
$query = "SELECT c.id, c.category_key, c.image_url,
          MAX(CASE WHEN ct.language_code = 'tr_TR' THEN ct.name END) as name_tr,
          MAX(CASE WHEN ct.language_code = 'en' THEN ct.name END) as name_en,
          MAX(CASE WHEN ct.language_code = 'ru' THEN ct.name END) as name_ru,
          MAX(CASE WHEN ct.language_code = 'zh' THEN ct.name END) as name_zh
          FROM categories c
          LEFT JOIN category_translations ct ON c.id = ct.category_id
          GROUP BY c.id, c.category_key, c.image_url
          ORDER BY c.id";
$stmt = $db->prepare($query);
$stmt->execute();
$categories = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kategoriler</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body class="pattern-bg">
    <div class="container mx-auto px-4 py-8">
        <div class="flex justify-between items-center mb-8">
            <h1 class="text-2xl font-bold text-gray-800">Kategoriler</h1>
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

        <!-- Kategori Ekleme Formu -->
        <div class="bg-white rounded-lg shadow-md p-6 mb-8">
            <h2 class="text-xl font-semibold text-gray-800 mb-4">Yeni Kategori Ekle</h2>
            <form method="POST" enctype="multipart/form-data" class="space-y-6">
                <input type="hidden" name="action" value="add">

                <div class="space-y-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Kategori Anahtarı</label>
                        <input type="text" name="category_key" required
                               class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                    </div>

                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Kategori Resmi</label>
                        <input type="file" name="category_image" accept="image/*"
                               class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                        <p class="mt-1 text-sm text-gray-500">Desteklenen formatlar: JPG, PNG, GIF</p>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-1">Türkçe İsim</label>
                            <input type="text" name="name_tr_TR" required
                                   class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-1">İngilizce İsim</label>
                            <input type="text" name="name_en" required
                                   class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-1">Rusça İsim</label>
                            <input type="text" name="name_ru" required
                                   class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-1">Çince İsim</label>
                            <input type="text" name="name_zh" required
                                   class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                        </div>
                    </div>
                </div>

                <button type="submit" class="w-full sm:w-auto px-6 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2">
                    Kategori Ekle
                </button>
            </form>
        </div>

        <!-- Kategoriler Listesi -->
        <div class="bg-white rounded-lg shadow-md p-6">
            <div class="flex justify-between items-center mb-6">
                <h2 class="text-xl font-semibold text-gray-800">Mevcut Kategoriler</h2>
                <div class="w-72">
                    <input type="text" id="searchInput" placeholder="Kategori ara..."
                           class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                </div>
            </div>

            <div class="overflow-x-auto">
                <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-gray-50">
                        <tr>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Anahtar</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Resim</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Türkçe</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">İngilizce</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Rusça</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Çince</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">İşlemler</th>
                        </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200">
                        <?php foreach ($categories as $category): ?>
                        <tr id="row_<?php echo $category['id']; ?>" class="hover:bg-gray-50">
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900"><?php echo $category['id']; ?></td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900"><?php echo $category['category_key']; ?></td>
                            <td class="px-6 py-4 whitespace-nowrap">
                                <?php if ($category['image_url']): ?>
                                    <img src="../<?php echo htmlspecialchars($category['image_url']); ?>"
                                         alt="<?php echo htmlspecialchars($category['name_tr']); ?>"
                                         class="h-10 w-10 object-cover rounded" />
                                <?php else: ?>
                                    <span class="text-gray-400">Resim yok</span>
                                <?php endif; ?>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900"><?php echo $category['name_tr']; ?></td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900"><?php echo $category['name_en']; ?></td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900"><?php echo $category['name_ru']; ?></td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900"><?php echo $category['name_zh']; ?></td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-4">
                                <button onclick="showEditForm(<?php echo $category['id']; ?>)"
                                        class="text-blue-600 hover:text-blue-900 text-xl">
                                    <i class="fas fa-edit"></i>
                                </button>
                                <form method="POST" class="inline" onsubmit="return confirm('Bu kategoriyi silmek istediğinizden emin misiniz?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="category_id" value="<?php echo $category['id']; ?>">
                                    <button type="submit" class="text-red-600 hover:text-red-900 text-xl">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </form>
                            </td>
                        </tr>
                        <!-- Düzenleme Formu -->
                        <tr id="edit_form_<?php echo $category['id']; ?>" class="edit-form hidden">
                            <td colspan="7" class="px-6 py-4">
                                <form method="POST" enctype="multipart/form-data" class="bg-gray-50 p-4 rounded-lg">
                                    <input type="hidden" name="action" value="edit">
                                    <input type="hidden" name="category_id" value="<?php echo $category['id']; ?>">
                                    <input type="hidden" name="old_image" value="<?php echo $category['image_url']; ?>">

                                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                                        <div>
                                            <label class="block text-sm font-medium text-gray-700 mb-1">Kategori Anahtarı</label>
                                            <input type="text" name="category_key" value="<?php echo $category['category_key']; ?>" required
                                                   class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                                        </div>
                                        <div>
                                            <label class="block text-sm font-medium text-gray-700 mb-1">Kategori Resmi</label>
                                            <?php if ($category['image_url']): ?>
                                                <div class="mb-2">
                                                    <img src="../<?php echo $category['image_url']; ?>" alt="Mevcut resim" class="h-20 w-20 object-cover rounded">
                                                </div>
                                            <?php endif; ?>
                                            <input type="file" name="category_image" accept="image/*"
                                                   class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                                            <p class="mt-1 text-sm text-gray-500">Yeni resim yüklemek için seçin</p>
                                        </div>
                                    </div>
                                    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                                        <div>
                                            <label class="block text-sm font-medium text-gray-700 mb-1">Türkçe İsim</label>
                                            <input type="text" name="name_tr_TR" value="<?php echo $category['name_tr']; ?>" required
                                                   class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                                        </div>
                                        <div>
                                            <label class="block text-sm font-medium text-gray-700 mb-1">İngilizce İsim</label>
                                            <input type="text" name="name_en" value="<?php echo $category['name_en']; ?>" required
                                                   class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                                        </div>
                                        <div>
                                            <label class="block text-sm font-medium text-gray-700 mb-1">Rusça İsim</label>
                                            <input type="text" name="name_ru" value="<?php echo $category['name_ru']; ?>" required
                                                   class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                                        </div>
                                        <div>
                                            <label class="block text-sm font-medium text-gray-700 mb-1">Çince İsim</label>
                                            <input type="text" name="name_zh" value="<?php echo $category['name_zh']; ?>" required
                                                   class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                                        </div>
                                    </div>
                                    <div class="flex justify-end items-center space-x-4 mt-4">
                                        <button type="submit" class="flex items-center space-x-2 text-green-600 hover:text-green-900 text-lg">
                                            <i class="fas fa-check"></i>
                                            <span>Kaydet</span>
                                        </button>
                                        <button type="button" onclick="hideEditForm(<?php echo $category['id']; ?>)"
                                                class="flex items-center space-x-2 text-gray-600 hover:text-gray-900 text-lg">
                                            <i class="fas fa-times"></i>
                                            <span>İptal</span>
                                        </button>
                                    </div>
                                </form>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script>
        function showEditForm(id) {
            document.querySelectorAll('.edit-form').forEach(form => form.classList.add('hidden'));
            document.getElementById('edit_form_' + id).classList.remove('hidden');
        }

        function hideEditForm(id) {
            document.getElementById('edit_form_' + id).classList.add('hidden');
        }

        // Filtreleme fonksiyonu
        document.addEventListener('DOMContentLoaded', function() {
            const searchInput = document.getElementById('searchInput');
            const tableRows = document.querySelectorAll('tbody tr:not(.edit-form)');

            function filterTable() {
                const searchText = searchInput.value.toLowerCase();

                tableRows.forEach(row => {
                    if (!row.id.startsWith('row_')) return; // Düzenleme formlarını atla

                    let showRow = true;

                    // Metin araması
                    if (searchText) {
                        const rowText = Array.from(row.querySelectorAll('td')).map(td => td.textContent.toLowerCase()).join(' ');
                        showRow = rowText.includes(searchText);
                    }

                    // Satırı göster/gizle
                    row.classList.toggle('hidden', !showRow);

                    // İlgili düzenleme formunu gizle
                    const editFormId = row.id.replace('row_', 'edit_form_');
                    const editForm = document.getElementById(editFormId);
                    if (editForm) {
                        editForm.classList.add('hidden');
                    }
                });
            }

            // Event listener
            searchInput.addEventListener('input', filterTable);
        });
    </script>
</body>
</html>
