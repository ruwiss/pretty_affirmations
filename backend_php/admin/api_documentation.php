<?php
require_once 'auth_check.php';
?>
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>API Dokümantasyonu - Pretty Affirmations</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
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
    </style>
</head>
<body class="pattern-bg min-h-screen">
    <div class="md:p-8">
        <div class="container mx-auto px-4 py-8">
            <h1 class="text-3xl font-bold text-gray-900 mb-8">API Dokümantasyonu</h1>

            <!-- API Endpoints -->
            <div class="space-y-8">
                <!-- Affirmations API -->
                <div class="bg-white rounded-lg shadow-md p-6">
                    <h2 class="text-xl font-semibold text-gray-800 mb-4">
                        <i class="fas fa-quote-right text-indigo-600 mr-2"></i>
                        Affirmations API
                    </h2>
                    <div class="mb-4">
                        <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-green-100 text-green-800">
                            GET
                        </span>
                        <code class="ml-2 text-sm text-gray-600">/api/affirmations.php</code>
                    </div>
                    <p class="text-gray-600 mb-4">Belirli kategorilere ve dile göre olumlamaları getirir.</p>

                    <h3 class="font-medium text-gray-700 mb-2">Parametreler:</h3>
                    <ul class="list-disc list-inside text-gray-600 mb-4 space-y-2">
                        <li><code>lang</code>: Dil kodu (en, ru, tr_TR, zh)</li>
                        <li><code>categories</code>: Kategori ID'leri (virgülle ayrılmış)</li>
                        <li><code>page</code>: Sayfa numarası</li>
                        <li><code>lastId</code>: Son görüntülenen olumlamanın ID'si</li>
                    </ul>
                </div>

                <!-- Categories API -->
                <div class="bg-white rounded-lg shadow-md p-6">
                    <h2 class="text-xl font-semibold text-gray-800 mb-4">
                        <i class="fas fa-tags text-indigo-600 mr-2"></i>
                        Categories API
                    </h2>
                    <div class="mb-4">
                        <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-green-100 text-green-800">
                            GET
                        </span>
                        <code class="ml-2 text-sm text-gray-600">/api/categories.php</code>
                    </div>
                    <p class="text-gray-600 mb-4">Mevcut kategorileri listeler.</p>

                    <h3 class="font-medium text-gray-700 mb-2">Parametreler:</h3>
                    <ul class="list-disc list-inside text-gray-600 mb-4 space-y-2">
                        <li><code>lang</code>: Dil kodu (en, ru, tr_TR, zh)</li>
                    </ul>
                </div>

                <!-- Daily Story API -->
                <div class="bg-white rounded-lg shadow-md p-6">
                    <h2 class="text-xl font-semibold text-gray-800 mb-4">
                        <i class="fas fa-book text-indigo-600 mr-2"></i>
                        Daily Story API
                    </h2>
                    <div class="mb-4">
                        <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-green-100 text-green-800">
                            GET
                        </span>
                        <code class="ml-2 text-sm text-gray-600">/api/daily-story.php</code>
                    </div>
                    <p class="text-gray-600 mb-4">Günlük hikayeyi getirir.</p>

                    <h3 class="font-medium text-gray-700 mb-2">Parametreler:</h3>
                    <ul class="list-disc list-inside text-gray-600 mb-4 space-y-2">
                        <li><code>lang</code>: Dil kodu (en, ru, tr_TR, zh)</li>
                    </ul>
                </div>
                <!-- Random Affirmations API -->
                <div class="bg-white rounded-lg shadow-md p-6">
                    <h2 class="text-xl font-semibold text-gray-800 mb-4">
                        <i class="fas fa-random text-indigo-600 mr-2"></i>
                        Random Affirmations API
                    </h2>
                    <div class="mb-4">
                        <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-green-100 text-green-800">
                            GET
                        </span>
                        <code class="ml-2 text-sm text-gray-600">/api/random-affirmations.php</code>
                    </div>
                    <p class="text-gray-600 mb-4">Belirli kategorilere ve dile göre rastgele 30 olumlama getirir.</p>

                    <h3 class="font-medium text-gray-700 mb-2">Parametreler:</h3>
                    <ul class="list-disc list-inside text-gray-600 mb-4 space-y-2">
                        <li><code>lang</code>: Dil kodu (en, ru, tr_TR, zh)</li>
                        <li><code>categories</code>: Kategori ID'leri (virgülle ayrılmış)</li>
                    </ul>
                </div>

                <!-- Daily Entry API -->
                <div class="bg-white rounded-lg shadow-md p-6">
                    <h2 class="text-xl font-semibold text-gray-800 mb-4">
                        <i class="fas fa-chart-line text-indigo-600 mr-2"></i>
                        Daily Entry API
                    </h2>
                    <div class="space-y-2">
                        <div>
                            <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-green-100 text-green-800">
                                GET
                            </span>
                            <code class="ml-2 text-sm text-gray-600">/api/daily-entry.php</code>
                        </div>
                        <div>
                            <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-blue-100 text-blue-800">
                                POST
                            </span>
                            <code class="ml-2 text-sm text-gray-600">/api/daily-entry.php</code>
                        </div>
                    </div>
                    <p class="text-gray-600 my-4">Günlük giriş sayılarını yönetir. GET ile mevcut sayıyı getirir, POST ile sayıyı artırır.</p>

                    <h3 class="font-medium text-gray-700 mb-2">Parametreler:</h3>
                    <ul class="list-disc list-inside text-gray-600 mb-4 space-y-2">
                        <li><code>lang</code>: Dil kodu (en, ru, tr_TR, zh)</li>
                    </ul>
                </div>
                <!-- Purchases API -->
                <div class="bg-white rounded-lg shadow-md p-6">
                    <h2 class="text-xl font-semibold text-gray-800 mb-4">
                        <i class="fas fa-shopping-cart text-indigo-600 mr-2"></i>
                        Purchases API
                    </h2>
                    <div class="mb-4">
                        <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-blue-100 text-blue-800">
                            POST
                        </span>
                        <code class="ml-2 text-sm text-gray-600">/api/purchases.php</code>
                    </div>
                    <p class="text-gray-600 mb-4">Satın alma işlem sayacı.</p>
                </div>

                <!-- Settings API -->
                <div class="bg-white rounded-lg shadow-md p-6">
                    <h2 class="text-xl font-semibold text-gray-800 mb-4">
                        <i class="fas fa-cog text-indigo-600 mr-2"></i>
                        Settings API
                    </h2>
                    <div class="mb-4">
                        <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-green-100 text-green-800">
                            GET
                        </span>
                        <code class="ml-2 text-sm text-gray-600">/api/settings.php</code>
                    </div>
                    <p class="text-gray-600 mb-4">Uygulama ayarlarını getirir.</p>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
