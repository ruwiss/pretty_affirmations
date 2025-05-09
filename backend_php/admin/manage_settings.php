<?php
include 'auth_check.php';
require_once '../config/Database.php';

$database = new Database();
$db = $database->getConnection();

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['change_password'])) {
    $current_password = $_POST['current_password'];
    $new_password = $_POST['new_password'];
    $confirm_password = $_POST['confirm_password'];

    try {
        // Mevcut şifreyi veritabanından al
        $query = "SELECT setting_value FROM app_settings WHERE setting_key = 'panel_password'";
        $stmt = $db->prepare($query);
        $stmt->execute();

        if ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $stored_password = $row['setting_value'];

            if ($current_password === $stored_password) {
                if ($new_password === $confirm_password) {
                    // Yeni şifreyi güncelle
                    $update_query = "UPDATE app_settings SET setting_value = ? WHERE setting_key = 'panel_password'";
                    $update_stmt = $db->prepare($update_query);

                    if ($update_stmt->execute([$new_password])) {
                        $success_message = "Şifre başarıyla güncellendi.";
                    } else {
                        $error_message = "Şifre güncellenirken bir hata oluştu.";
                    }
                } else {
                    $error_message = "Yeni şifreler eşleşmiyor.";
                }
            } else {
                $error_message = "Mevcut şifre yanlış.";
            }
        } else {
            $error_message = "Sistem hatası: Şifre ayarı bulunamadı!";
        }
    } catch(PDOException $e) {
        $error_message = "Veritabanı hatası: " . $e->getMessage();
    }
}
?>
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ayarlar Yönetimi</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        .modal {
            display: none;
            opacity: 0;
            transition: opacity 0.2s ease-in-out;
            pointer-events: none;
        }
        .modal.show {
            display: flex !important;
            opacity: 1;
            pointer-events: auto;
        }
        .truncate {
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            max-width: 200px;
        }
        body {
            padding: 0;
            margin: 0;
            background: transparent;
        }
        .pattern-bg {
            background-color: #f8fafc;
            background-image: url("../assets/patterns/background.svg");
        }
    }
    </style>
</head>
<body class="pattern-bg min-h-screen">
    <div class="container mx-auto px-4 py-8">
        <!-- Main Content -->

            <?php if (isset($success_message)): ?>
                <div class="mb-6 p-4 rounded-lg bg-green-100 text-green-700 border border-green-200">
                    <div class="flex items-center">
                        <i class="fas fa-check-circle mr-2"></i>
                        <?php echo $success_message; ?>
                    </div>
                </div>
            <?php endif; ?>

            <?php if (isset($error_message)): ?>
                <div class="mb-6 p-4 rounded-lg bg-red-100 text-red-700 border border-red-200">
                    <div class="flex items-center">
                        <i class="fas fa-exclamation-circle mr-2"></i>
                        <?php echo $error_message; ?>
                    </div>
                </div>
            <?php endif; ?>

            <!-- Settings Grid -->
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <!-- Password Change Section -->
                <div class="bg-white rounded-lg border border-gray-200 p-6">
                    <h2 class="text-xl font-semibold mb-6 pb-2 border-b border-gray-100">
                        <i class="fas fa-lock mr-2 text-gray-600"></i>
                        Şifre Değiştir
                    </h2>
                    <form method="POST" onsubmit="return validatePasswordForm()">
                        <div class="space-y-4">
                            <div>
                                <label for="current_password" class="block text-sm font-medium text-gray-700 mb-1">
                                    Mevcut Şifre
                                </label>
                                <input type="password" id="current_password" name="current_password" required
                                    class="w-full px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors">
                            </div>
                            <div>
                                <label for="new_password" class="block text-sm font-medium text-gray-700 mb-1">
                                    Yeni Şifre
                                </label>
                                <input type="password" id="new_password" name="new_password" required
                                    class="w-full px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors">
                            </div>
                            <div>
                                <label for="confirm_password" class="block text-sm font-medium text-gray-700 mb-1">
                                    Yeni Şifre (Tekrar)
                                </label>
                                <input type="password" id="confirm_password" name="confirm_password" required
                                    class="w-full px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors">
                            </div>
                            <button type="submit" name="change_password" class="w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-lg transition-colors duration-200">
                                <i class="fas fa-save mr-2"></i>
                                Şifreyi Güncelle
                            </button>
                        </div>
                    </form>
                </div>

                <!-- Other Settings Section -->
                <div class="bg-white rounded-lg border border-gray-200 p-6">
                    <h2 class="text-xl font-semibold mb-6 pb-2 border-b border-gray-100">
                        <i class="fas fa-cog mr-2 text-gray-600"></i>
                        Diğer Ayarlar
                    </h2>
                    <div id="settings-list" class="space-y-4">
                        <!-- Settings will be loaded here -->
                    </div>
                </div>
            </div>

    </div>

    <!-- Edit Setting Modal -->
    <div id="editModal" class="modal fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center p-4">
        <div class="bg-white rounded-xl max-w-lg w-full p-6 relative">
            <button onclick="closeModal()" class="absolute top-4 right-4 text-gray-400 hover:text-gray-600">
                <i class="fas fa-times"></i>
            </button>
            <h3 class="text-lg font-semibold mb-4">Ayarı Düzenle</h3>
            <form id="editForm" class="space-y-4">
                <input type="hidden" id="edit_key" name="key">
                <div>
                    <label for="edit_value" class="block text-sm font-medium text-gray-700 mb-1">Değer</label>
                    <input type="text" id="edit_value" name="value" class="w-full px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                </div>
                <div class="flex justify-end gap-3">
                    <button type="button" onclick="closeModal()" class="px-4 py-2 text-gray-600 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors duration-200">
                        İptal
                    </button>
                    <button type="submit" class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors duration-200">
                        Kaydet
                    </button>
                </div>
            </form>
        </div>
    </div>

    <template id="setting-template">
        <div class="setting-item bg-gray-50 rounded-lg p-4 border border-gray-200">
            <div class="flex flex-wrap justify-between items-center gap-4">
                <div class="space-y-1">
                    <div class="font-medium text-gray-900"></div>
                    <div class="text-sm text-gray-600 truncate"></div>
                </div>
                <button class="edit-button inline-flex items-center px-3 py-2 text-sm bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors duration-200">
                    <i class="fas fa-edit mr-2"></i>
                    Düzenle
                </button>
            </div>
        </div>
    </template>

    <script>
        // Ayarları yükle
        function loadSettings() {
            fetch('../api/settings.php')
                .then(response => response.json())
                .then(response => {
                    if (response.status === 'success') {
                        const settingsList = document.getElementById('settings-list');
                        const template = document.getElementById('setting-template');
                        settingsList.innerHTML = '';

                        // Convert settings object to array of {key, value} pairs
                        const settings = Object.entries(response.data).map(([key, value]) => ({
                            key: key,
                            value: value
                        }));

                        settings.forEach(setting => {
                            if (setting.key !== 'panel_password') {
                                const clone = template.content.cloneNode(true);
                                const item = clone.querySelector('.setting-item');
                                item.dataset.key = setting.key;
                                item.dataset.value = setting.value;
                                item.querySelector('.font-medium').textContent = setting.key;
                                item.querySelector('.text-sm').textContent = setting.value;

                                // Add click event to edit button
                                const editButton = item.querySelector('.edit-button');
                                editButton.addEventListener('click', function() {
                                    editSetting(this);
                                });

                                settingsList.appendChild(clone);
                            }
                        });
                    } else {
                        console.error('Error loading settings:', response.message);
                    }
                })
                .catch(error => console.error('Error:', error));
        }

        // Modal işlemleri
        const modal = document.getElementById('editModal');
        const editForm = document.getElementById('editForm');

        function editSetting(button) {
            const item = button.closest('.setting-item');
            const key = item.dataset.key;
            const value = item.dataset.value;

            document.getElementById('edit_key').value = key;
            document.getElementById('edit_value').value = value;
            modal.style.display = 'flex';
            setTimeout(() => {
                modal.classList.add('show');
            }, 10);
        }

        function closeModal() {
            modal.classList.remove('show');
            setTimeout(() => {
                modal.style.display = 'none';
            }, 200);
        }

        editForm.onsubmit = function(e) {
            e.preventDefault();
            const setting_key = document.getElementById('edit_key').value;
            const setting_value = document.getElementById('edit_value').value;

            fetch('../api/settings.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ setting_key, setting_value })
            })
            .then(response => response.json())
            .then(data => {
                if (data.status === 'success') {
                    loadSettings();
                    closeModal();
                } else {
                    alert('Hata: ' + (data.message || 'Ayar güncellenirken bir hata oluştu'));
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('Hata: Ayar güncellenirken bir hata oluştu');
            });
        };

        function validatePasswordForm() {
            const newPassword = document.getElementById('new_password').value;
            const confirmPassword = document.getElementById('confirm_password').value;

            if (newPassword !== confirmPassword) {
                alert('Yeni şifreler eşleşmiyor!');
                return false;
            }
            return true;
        }

        // Sayfa yüklendiğinde ayarları yükle
        document.addEventListener('DOMContentLoaded', function() {
            loadSettings();
        });
    </script>
</body>
</html>
