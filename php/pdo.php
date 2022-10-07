<?php
  # Singleton instance av PDO
  $pdo = new PDO("mysql:dbname=a21oligu;host=localhost", "a21oligu", "a21oligu");
  $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

  function selectAllFromTable($tableName) {
    global $pdo;
    $query = "SELECT * FROM $tableName";
    $stmt = $pdo->prepare($query, array(PDO::FETCH_ASSOC));
    $stmt->execute();
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    return $result;
  }

  # Funktion för att skapa tabell med data
  function createTable($data, $extra = null) {
    if (count($data) === 0) return;
    $keys = array_keys($data[0]);
    echo "<table>";
    echo "<tr>";
    foreach($keys as $col){
        echo "<th>" . $col . "</th>";
    }
    if ($extra) {
      echo "<th></th>";
    }
    echo "<tr>";

    foreach($data as $row) {
      echo "<tr class='row'>";
      foreach($row as $key => $val) {
        if(!is_string($key)) continue;
          
        echo "<td class='data'>" . $val . "</td>";
      }
      
      if ($extra) {
        $method = $extra["method"];
        $action = $extra["action"];
        $text = $extra["text"];
        $k = $extra["key"];
        $value = $row[$k];

        echo "<td class='nopadding'>
          <form action='$action' method='$method'>
            <input type='hidden' name='$k' value='$value'>
            <button id='$text' type='submit'>$text</button>
          </form>
        </td>";
      }
      echo "<tr>";
    }
    echo "</table>";
  }

  # Generera ett burknummer för pölse
  function generateBurkNr() {
    $numstring = "";
    for ($i = 0; $i < 14; $i++) {
      $num = (string) rand(0, 9);
      $numstring .= $num;
    }

    $res = implode([substr($numstring, 0, 3), ".", substr($numstring, 3, 4), "-", substr($numstring, 7, 3), ".", substr($numstring, 10, 4)]);

    return $res;
  }
?>
