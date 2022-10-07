<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Document</title>
</head>
<body>
  <?php
    require "./pdo.php";

    # Hämta data från tabeller
    $klaner = selectAllFromTable("Klan");
    $underarter = selectAllFromTable("Underart");
    $stanker = selectAllFromTable("Stank");
    $alla_spann = selectAllFromTable("Spann");

    if (isset($_POST["nr"], $_POST["klan"], $_POST["underart"], $_POST["stank"], $_POST["spann"])) {
      try {
        $trans = "INSERT INTO Ren(nr, klan, underart, stank, spann, lön, typ) VALUES (:nr, :klan, :underart, :stank, :spann, 2000, 'tjänste')";
        $statement = $pdo->prepare($trans);
        if(strlen($_POST["nr"]) !== 11) {
          echo "Löpnummeret är för kort";
          return;
        };

        $statement->execute([
          ":nr" => $_POST["nr"],
          ":klan" => $_POST["klan"],
          ":underart" => $_POST["underart"],
          ":stank" => $_POST["stank"],
          ":spann" => $_POST["spann"]
        ]);
  
        echo "Ny ren med löpnummer " . $_POST["nr"] . " lades till!";
      } catch (PDOException $e) {
        echo "Failed to add Ren";
        unset($_POST);
      }
    }
  ?>

  <form action="./datadefinition.php?tab=skapa_ny" method="post">
    <input type="text" name="nr" id="nr" placeholder="Löpnummer">
    <select name="klan" id="klan">
      <option value="-1">-- Klan --</option>
      <?php
        foreach($klaner as $klan) {
          $namn = $klan["namn"];
          $id = $klan["id"];
          echo "<option value='$id'>$namn</option>";
        }
      ?>
    </select>
    <select name="underart" id="underart">
      <option value="-1">-- Underart --</option>
      <?php
        foreach($underarter as $underart) {
          $namn = $underart["namn"];
          $id = $underart["id"];
          echo "<option value='$id'>$namn</option>";
        }
      ?>
    </select>
    <select name="stank" id="stank">
      <option value="-1">-- Stank --</option>
      <?php
        foreach($stanker as $stank) {
          $namn = $stank["namn"];
          $id = $stank["id"];
          echo "<option value='$id'>$namn</option>";
        }
      ?>
    </select>
    <select name="spann" id="spann">
      <option value="-1">-- Spann --</option>
      <?php
        foreach($alla_spann as $spann) {
          $namn = $spann["namn"];
          echo "<option value='$namn'>$namn</option>";
        }
      ?>
    </select>
    <button type="submit">Lägg till ren</button>
  </form>
</body>
</html>

