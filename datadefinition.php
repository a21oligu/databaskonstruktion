<html>
    <head>
        <title>a21oligu - php</title>
        
    </head>
    
</html>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PHP a21oligu</title>
    <style>
        td {
            padding: 1rem;
        }
    </style>
</head>
<body>
    <h1>a21oligu datadefinition</h1>
    <?php
        $pdo = new PDO("mysql:dbname=a21oligu;host=localhost", "tomtefar", "tomten");
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

        function createTable($test) {
            print_r($test);
        }

        $query_alla_renar = "SELECT * FROM Ren";
        $stmt = $pdo->prepare($query_alla_renar, array(PDO::FETCH_ASSOC));
        
        $stmt->execute();

        $renar = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "<table border=1>";
            foreach($renar as $ren) {
                
                echo "<tr>";
                foreach($ren as $key => $val) {
                    //if(!is_string($key)) continue;
                    
                    echo "<td>" . $val . "</td>";
                    
                }
                echo "<tr>";
            }
        echo "</table>";
    ?>

    <?php
        $arr = array(array(10, 10, 1100, 111000));
        createTable($arr);
    ?>

    </body>
</html>
