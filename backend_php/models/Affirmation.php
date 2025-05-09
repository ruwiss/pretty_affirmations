<?php
class Affirmation {
    private $conn;
    private $table_name = "affirmations";

    public function __construct($db) {
        $this->conn = $db;
    }

    public function getAffirmations($language_code, $categories, $offset = 0, $limit = 6, $lastId = null) {
        $categoriesStr = implode(',', array_fill(0, count($categories), '?'));
        
        $query = "SELECT a.id, a.content, c.category_key, ct.name as category_name 
                 FROM " . $this->table_name . " a
                 JOIN categories c ON a.category_id = c.id
                 JOIN category_translations ct ON c.id = ct.category_id
                 WHERE a.language_code = ? 
                 AND ct.language_code = ?
                 AND a.category_id IN ($categoriesStr)";
        
        // Add lastId condition if provided
        if ($lastId !== null) {
            $query .= " AND a.id > ?";
        }
        
        $query .= " ORDER BY a.id ASC LIMIT ? OFFSET ?";

        $stmt = $this->conn->prepare($query);
        
        // Tüm parametreleri bir diziye ekleyelim
        $bindParams = array_merge(
            [$language_code, $language_code],
            $categories
        );
        
        // lastId parametresini ekleyelim
        if ($lastId !== null) {
            $bindParams[] = (int)$lastId;
        }
        
        // LIMIT ve OFFSET parametrelerini integer olarak ekleyelim
        $bindParams[] = (int)$limit;
        $bindParams[] = (int)$offset;
        
        // PDO parametrelerini bağlayalım ve integer tiplerini belirtelim
        foreach ($bindParams as $key => $value) {
            $paramType = (in_array($key, [count($bindParams)-1, count($bindParams)-2]) || ($lastId !== null && $key === count($bindParams)-3)) ? PDO::PARAM_INT : PDO::PARAM_STR;
            $stmt->bindValue($key + 1, $value, $paramType);
        }
        
        $stmt->execute();
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getCategories($language_code) {
        $query = "SELECT c.id, c.category_key, c.image_url, ct.name 
                 FROM categories c
                 JOIN category_translations ct ON c.id = ct.category_id
                 WHERE ct.language_code = ?
                 ORDER BY c.id";

        $stmt = $this->conn->prepare($query);
        $stmt->execute([$language_code]);
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getRandomAffirmations($language_code, $categories, $limit = 30) {
        $categoriesStr = implode(',', array_fill(0, count($categories), '?'));
        
        $query = "SELECT a.id, a.content, c.category_key, ct.name as category_name 
                 FROM " . $this->table_name . " a
                 JOIN categories c ON a.category_id = c.id
                 JOIN category_translations ct ON c.id = ct.category_id
                 WHERE a.language_code = ? 
                 AND ct.language_code = ?
                 AND a.category_id IN ($categoriesStr)
                 ORDER BY RAND()
                 LIMIT ?";

        $stmt = $this->conn->prepare($query);
        
        // Parametreleri diziye ekleyelim
        $bindParams = array_merge(
            [$language_code, $language_code],
            $categories
        );
        
        // LIMIT parametresini ekleyelim
        $bindParams[] = (int)$limit;
        
        // PDO parametrelerini bağlayalım
        foreach ($bindParams as $key => $value) {
            $paramType = ($key === count($bindParams)-1) ? PDO::PARAM_INT : PDO::PARAM_STR;
            $stmt->bindValue($key + 1, $value, $paramType);
        }
        
        $stmt->execute();
        
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}
?>
