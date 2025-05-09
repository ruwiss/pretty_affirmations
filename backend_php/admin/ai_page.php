<?php
require_once 'auth_check.php';
require_once '../config/Database.php';
require_once '../config/GeminiAPI.php';

$database = new Database();
$db = $database->getConnection();

try {
    $gemini = new GeminiAPI($db);

    // Kategorileri al
    $stmt = $db->prepare("SELECT c.category_key, ct.name as category_name
                         FROM categories c
                         LEFT JOIN category_translations ct ON c.id = ct.category_id
                         WHERE ct.language_code = 'tr_TR'
                         ORDER BY c.id");
    $stmt->execute();
    $categories = $stmt->fetchAll(PDO::FETCH_ASSOC);
} catch (Exception $e) {
    $apiError = $e->getMessage();
}
?>
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Yapay Zeka Yönetimi</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
    body {
        padding: 0;
        margin: 0;
        background: transparent;
    }
    .pattern-bg {
        background-color: #f8fafc;
        background-image: url("../assets/patterns/background.svg");
    }
    .tab-button {
        color: #6B7280;
        border-bottom: 2px solid transparent;
    }
    .tab-button:hover {
        color: #4B5563;
    }
    .active-tab {
        color: #2563EB;
        border-bottom: 2px solid #2563EB;
        background-color: #EFF6FF;
    }
    /* Webkit scroll styles */
    .overflow-y-auto::-webkit-scrollbar {
        width: 6px;
    }
    .overflow-y-auto::-webkit-scrollbar-track {
        background: #f1f1f1;
        border-radius: 3px;
    }
    .overflow-y-auto::-webkit-scrollbar-thumb {
        background: #c1c1c1;
        border-radius: 3px;
    }
    .overflow-y-auto::-webkit-scrollbar-thumb:hover {
        background: #a1a1a1;
    }
</style>
</head>
<body class="pattern-bg">
    <div class="container mx-auto px-4 py-8">
        <h1 class="text-2xl font-bold text-gray-800 mb-6">Yapay Zeka Yönetimi</h1>

        <?php if (isset($apiError)): ?>
        <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-6" role="alert">
            <strong class="font-bold">Hata!</strong>
            <span class="block sm:inline"><?php echo htmlspecialchars($apiError); ?></span>
        </div>
        <?php endif; ?>

        <!-- Loading Popup -->
        <div id="loading-popup" class="fixed inset-0 bg-gray-600 bg-opacity-50 hidden flex items-center justify-center z-50">
            <div class="bg-white p-6 rounded-lg shadow-xl flex items-center space-x-4">
                <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
                <p class="text-gray-700">Lütfen bekleyin...</p>
            </div>
        </div>

        <!-- Affirmations Result Popup -->
        <div id="affirmations-popup" class="fixed inset-0 bg-gray-600 bg-opacity-50 hidden z-50">
            <div class="flex items-center justify-center min-h-screen p-4">
                <div class="bg-white rounded-lg shadow-xl w-full max-w-4xl max-h-[90vh] flex flex-col">
                    <div class="p-6 flex flex-col h-full">
                        <div class="flex justify-between items-center mb-4">
                            <h3 class="text-lg font-semibold">Çeviri Sonuçları</h3>
                            <button onclick="hideAffirmationsPopup()" class="text-gray-500 hover:text-gray-700">
                                <i class="fas fa-times"></i>
                            </button>
                        </div>

                        <div class="mb-4">
                            <label class="block text-sm font-medium text-gray-700 mb-2">Kategori Seçimi</label>
                            <select id="category-select" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                                <?php foreach ($categories as $category): ?>
                                <option value="<?php echo htmlspecialchars($category['category_key']); ?>">
                                    <?php echo htmlspecialchars($category['category_name']); ?>
                                </option>
                                <?php endforeach; ?>
                            </select>
                        </div>

                        <div class="flex-1 overflow-y-auto min-h-0">
                            <div class="grid grid-cols-1 md:grid-cols-4 gap-4 h-[60vh]">
                                <div class="flex flex-col">
                                    <h4 class="font-semibold mb-2 sticky top-0 bg-white z-10 py-2">Türkçe</h4>
                                    <div id="tr-translations" class="space-y-2 overflow-y-auto flex-1 pr-2">
                                        <!-- İçerik buraya gelecek -->
                                    </div>
                                </div>

                                <div class="flex flex-col">
                                    <h4 class="font-semibold mb-2 sticky top-0 bg-white z-10 py-2">İngilizce</h4>
                                    <div id="en-translations" class="space-y-2 overflow-y-auto flex-1 pr-2">
                                        <!-- İçerik buraya gelecek -->
                                    </div>
                                </div>

                                <div class="flex flex-col">
                                    <h4 class="font-semibold mb-2 sticky top-0 bg-white z-10 py-2">Rusça</h4>
                                    <div id="ru-translations" class="space-y-2 overflow-y-auto flex-1 pr-2">
                                        <!-- İçerik buraya gelecek -->
                                    </div>
                                </div>

                                <div class="flex flex-col">
                                    <h4 class="font-semibold mb-2 sticky top-0 bg-white z-10 py-2">Çince</h4>
                                    <div id="zh-translations" class="space-y-2 overflow-y-auto flex-1 pr-2">
                                        <!-- İçerik buraya gelecek -->
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="mt-4 pt-4 border-t">
                            <div class="flex justify-end">
                                <button
                                    onclick="saveAffirmations()"
                                    class="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
                                >
                                    Tüm Çevirileri Kaydet
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Story Translations Popup -->
        <div id="story-popup" class="fixed inset-0 bg-gray-600 bg-opacity-50 hidden z-50">
            <div class="flex items-center justify-center min-h-screen p-4">
                <div class="bg-white rounded-lg shadow-xl w-full max-w-4xl max-h-[90vh] flex flex-col">
                    <div class="p-6 flex flex-col h-full">
                        <div class="flex justify-between items-center mb-4">
                            <h3 class="text-lg font-semibold">Hikaye Çeviri Sonuçları</h3>
                            <button onclick="hideStoryPopup()" class="text-gray-500 hover:text-gray-700">
                                <i class="fas fa-times"></i>
                            </button>
                        </div>
                        <!-- Language Tabs -->
                        <div class="border-b border-gray-200 mb-4">
                            <nav class="flex space-x-4" aria-label="Tabs">
                                <button onclick="switchLanguageTab('tr')" id="tab-tr" class="tab-button px-4 py-2 text-sm font-medium rounded-t-lg active-tab" aria-current="page">Türkçe</button>
                                <button onclick="switchLanguageTab('en')" id="tab-en" class="tab-button px-4 py-2 text-sm font-medium rounded-t-lg">İngilizce</button>
                                <button onclick="switchLanguageTab('ru')" id="tab-ru" class="tab-button px-4 py-2 text-sm font-medium rounded-t-lg">Rusça</button>
                                <button onclick="switchLanguageTab('zh')" id="tab-zh" class="tab-button px-4 py-2 text-sm font-medium rounded-t-lg">Çince</button>
                            </nav>
                        </div>
                        <!-- Translation Content -->
                        <div class="flex-1 overflow-y-auto min-h-0">
                            <div class="space-y-4">
                                <div class="translation-item hidden" id="tr-story">
                                    <h4 class="font-semibold mb-2 story-title sticky top-0 bg-white"></h4>
                                    <div class="p-4 bg-gray-50 rounded-lg"></div>
                                </div>
                                <div class="translation-item hidden" id="en-story">
                                    <h4 class="font-semibold mb-2 story-title sticky top-0 bg-white"></h4>
                                    <div class="p-4 bg-gray-50 rounded-lg"></div>
                                </div>
                                <div class="translation-item hidden" id="ru-story">
                                    <h4 class="font-semibold mb-2 story-title sticky top-0 bg-white"></h4>
                                    <div class="p-4 bg-gray-50 rounded-lg"></div>
                                </div>
                                <div class="translation-item hidden" id="zh-story">
                                    <h4 class="font-semibold mb-2 story-title sticky top-0 bg-white"></h4>
                                    <div class="p-4 bg-gray-50 rounded-lg"></div>
                                </div>
                            </div>
                        </div>
                        <div class="mt-4 pt-4 border-t">
                            <div class="flex justify-end">
                                <button
                                    onclick="saveStoryTranslations()"
                                    class="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
                                >
                                    Tüm Çevirileri Kaydet
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-lg shadow-md p-6">
            <div class="p-4 border rounded-lg bg-gray-50">
                <h2 class="text-lg font-semibold mb-4">Model Seçimi</h2>
                <div class="relative">
                    <select name="ai_model" id="ai_model" class="block w-full px-4 py-3 text-base border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                        <option value="">Model seçiniz</option>
                        <option value="gemini-1.5-pro-002">gemini-1.5-pro-002</option>
                        <option value="gemini-1.5-flash-002" selected>gemini-1.5-flash-002</option>
                        <option value="gemini-1.5-flash-8b">gemini-1.5-flash-8b</option>
                        <option value="gemini-1.5-pro">gemini-1.5-pro</option>
                        <option value="gemini-1.5-flash">gemini-1.5-flash</option>
                    </select>
                </div>
            </div>

            <!-- Affirmations Section -->
            <div class="p-4 border rounded-lg bg-gray-50 mt-6">
                <h2 class="text-lg font-semibold mb-4">Olumlama Çevirisi</h2>
                <div class="space-y-4">
                    <textarea
                        id="affirmations-input"
                        class="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                        rows="10"
                        placeholder="Her satıra bir cümle yazın (maksimum 10 satır)"
                        onkeyup="checkLines(this)"
                    ></textarea>
                    <button
                        id="translate-button"
                        class="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
                        onclick="translateText('affirmations')"
                    >
                        Çevir
                    </button>
                </div>
            </div>

            <!-- Story Section -->
            <div class="p-4 border rounded-lg bg-gray-50 mt-6">
                <h2 class="text-lg font-semibold mb-4">Hikaye Çevir / Oluştur</h2>
                <div class="space-y-4">
                    <div class="mb-4">
                        <label for="custom-prompt" class="block text-sm font-medium text-gray-700 mb-2">Custom Prompt</label>
                        <textarea
                            id="custom-prompt"
                            class="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                            rows="3"
                            placeholder="Özel talimatlarınızı buraya yazın..."
                        ></textarea>
                    </div>
                    <textarea
                        id="story-input"
                        class="w-full p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                        rows="10"
                        placeholder="Hikaye konusunu veya hikayeyi buraya yazın..."
                    ></textarea>
                    <div class="flex justify-end space-x-4">
                        <button
                            onclick="createStory()"
                            id="create-story-button"
                            class="px-6 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2"
                        >
                            Hikaye Oluştur
                        </button>
                        <button
                            onclick="translateText('story')"
                            id="translate-story-button"
                            class="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
                        >
                            Çeviri Yap
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
    let currentTranslations = null;

    function showLoading() {
        document.getElementById('loading-popup').classList.remove('hidden');
    }

    function hideLoading() {
        document.getElementById('loading-popup').classList.add('hidden');
    }

    function showAffirmationsPopup(data) {
        currentTranslations = data;
        const popup = document.getElementById('affirmations-popup');

        // Kategoriyi seç
        document.getElementById('category-select').value = data.suggested_category;

        // Çevirileri göster
        const languages = ['tr_TR', 'en', 'ru', 'zh'];
        const containerIds = ['tr-translations', 'en-translations', 'ru-translations', 'zh-translations'];

        languages.forEach((lang, index) => {
            const container = document.getElementById(containerIds[index]);
            container.innerHTML = ''; // Clear previous content

            data.translations[lang].forEach((text, i) => {
                const div = document.createElement('div');
                div.className = 'p-2 bg-gray-50 rounded text-sm';
                div.textContent = text;
                container.appendChild(div);
            });
        });

        popup.classList.remove('hidden');
    }

    function hideAffirmationsPopup() {
        document.getElementById('affirmations-popup').classList.add('hidden');
        currentTranslations = null;
    }

    async function saveAffirmations() {
        if (!currentTranslations) return;

        const selectedCategory = document.getElementById('category-select').value;
        const translations = currentTranslations.translations;

        try {
            const response = await fetch('save_affirmations.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    category: selectedCategory,
                    translations: translations
                })
            });

            const result = await response.json();

            if (result.success) {
                alert('Çeviriler başarıyla kaydedildi!');
                hideAffirmationsPopup();
            } else {
                alert('Hata: ' + (result.error || 'Çeviriler kaydedilirken bir hata oluştu'));
            }
        } catch (error) {
            console.error('Error:', error);
            alert('Hata: Çeviriler kaydedilirken bir hata oluştu');
        }
    }

    function checkLines(textarea) {
        let lines = textarea.value.split('\n');
        if (lines.length > 10) {
            textarea.value = lines.slice(0, 10).join('\n');
        }
    }

    function translateText(type) {
        const input = document.getElementById(`${type}-input`).value;
        const model = document.getElementById('ai_model').value;
        const customPrompt = document.getElementById('custom-prompt').value;

        if (!input.trim()) {
            alert('Lütfen çevrilecek metni girin');
            return;
        }

        // Disable buttons before showing loading
        document.getElementById('translate-button').disabled = true;
        document.getElementById('translate-story-button').disabled = true;

        showLoading();

        fetch(`translate_${type}.php`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                text: input,
                model: model,
                customPrompt: customPrompt
            })
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                // Hide loading before showing popups
                hideLoading();
                console.log('Translation API Response:', data);

                if (type === 'affirmations') {
                    showAffirmationsPopup(data.data);
                } else if (type === 'story') {
                    console.log('Story translations received:', data.data.translations);
                    showStoryPopup(data.data.translations);
                }
            } else {
                hideLoading();
                alert('Çeviri sırasında bir hata oluştu: ' + data.error);
            }
        })
        .catch(error => {
            hideLoading();
            console.error('Error:', error);
            alert('Bir hata oluştu: ' + error);
        })
        .finally(() => {
            // Re-enable buttons
            document.getElementById('translate-button').disabled = false;
            document.getElementById('translate-story-button').disabled = false;
        });
    }

    function createStory() {
        const topic = document.getElementById('story-input').value;
        const model = document.getElementById('ai_model').value;
        const customPrompt = document.getElementById('custom-prompt').value;

        if (!topic.trim()) {
            alert('Lütfen bir hikaye konusu girin');
            return;
        }

        // Disable buttons before showing loading
        document.getElementById('translate-button').disabled = true;
        document.getElementById('translate-story-button').disabled = true;
        document.getElementById('create-story-button').disabled = true;

        showLoading();

        fetch('../api/create_story.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                topic: topic,
                model: model,
                customPrompt: customPrompt
            })
        })
        .then(response => response.json())
        .then(data => {
            hideLoading();
            console.log('Story creation response:', data);

            if (data.success) {
                showStoryPopup(data.data.translations);
            } else {
                alert('Hikaye oluşturulurken bir hata oluştu: ' + data.error);
            }
        })
        .catch(error => {
            hideLoading();
            console.error('Error:', error);
            alert('Bir hata oluştu: ' + error);
        })
        .finally(() => {
            // Re-enable buttons
            document.getElementById('translate-button').disabled = false;
            document.getElementById('translate-story-button').disabled = false;
            document.getElementById('create-story-button').disabled = false;
        });
    }

    document.addEventListener('DOMContentLoaded', function() {
        const defaultModel = 'gemini-1.5-flash-002';
        document.getElementById('ai_model').value = defaultModel;
    });

    let currentStoryTranslations = null;

    function showStoryPopup(translations) {
        if (!translations) {
            console.error('No translations provided');
            return;
        }

        // Store translations for later use
        currentStoryTranslations = translations;
        console.log('Stored translations:', currentStoryTranslations);

        const popup = document.getElementById('story-popup');

        if (!popup) {
            console.error('Story popup element not found');
            return;
        }

        // Map for converting API language codes to HTML IDs
        const langToId = {
            'tr_TR': 'tr',
            'en': 'en',
            'ru': 'ru',
            'zh': 'zh'
        };

        // Hide all translation items
        document.querySelectorAll('.translation-item').forEach(item => {
            item.classList.add('hidden');
        });

        // Fill in all translations
        Object.entries(translations).forEach(([lang, data]) => {
            const containerId = `${langToId[lang]}-story`;
            const container = document.getElementById(containerId);

            if (container) {
                const contentDiv = container.querySelector('div');
                if (contentDiv && data.content && data.content.trim() !== '') {
                    contentDiv.textContent = data.content;
                    console.log(`Set translation for ${lang}:`, data);
                }
                const titleDiv = container.querySelector('.story-title');
                if (titleDiv && data.title && data.title.trim() !== '') {
                    titleDiv.textContent = data.title;
                    console.log(`Set title for ${lang}:`, data.title);
                }
            }
        });

        // Show popup and activate first tab
        popup.classList.remove('hidden');
        switchLanguageTab('tr');
    }

    function switchLanguageTab(lang) {
        // Hide all translation items
        document.querySelectorAll('.translation-item').forEach(item => {
            item.classList.add('hidden');
        });

        // Remove active class from all tabs
        document.querySelectorAll('.tab-button').forEach(tab => {
            tab.classList.remove('active-tab');
        });

        // Show selected translation and activate tab
        const container = document.getElementById(`${lang}-story`);
        const tab = document.getElementById(`tab-${lang}`);

        if (container) {
            container.classList.remove('hidden');
        }
        if (tab) {
            tab.classList.add('active-tab');
        }
    }

    function hideStoryPopup() {
        document.getElementById('story-popup').classList.add('hidden');
        currentStoryTranslations = null;
    }

    async function saveStoryTranslations() {
        if (!currentStoryTranslations) {
            alert('Çeviri verileri bulunamadı');
            return;
        }

        try {
            console.log('Current translations before save:', currentStoryTranslations);

            const requestData = {
                translations: currentStoryTranslations
            };
            console.log('Request data:', requestData);
            console.log('Request JSON:', JSON.stringify(requestData));

            const response = await fetch('save_story.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(requestData)
            });

            const result = await response.json();
            console.log('Server response:', result);

            if (result.success) {
                alert('Hikaye çevirileri başarıyla kaydedildi!');
                hideStoryPopup();
            } else {
                console.error('Save error:', result.error);
                alert('Hata: ' + (result.error || 'Hikaye çevirileri kaydedilirken bir hata oluştu'));
            }
        } catch (error) {
            console.error('Save error:', error);
            alert('Hata: Hikaye çevirileri kaydedilirken bir hata oluştu');
        }
    }
    </script>
</body>
</html>
