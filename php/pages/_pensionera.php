<?php
  # Om inget nr är specifierat, omdirigera
  if(!isset($_POST["nr"])) {
    header("Location: datadefinition.php?tab=search");
    exit();
  }

  require "pdo.php"; 
  $nr = (string) $_POST["nr"];
  echo "<h1>Pensionera ren med löpnummer [$nr]?";
?>

<?php 
  $burknr = generateBurkNr();
  echo "<form id='pensionera-form' method='post'>";
  echo "<input type='hidden' name='burknr' value='$burknr'>";
  echo "<input type='hidden' name='nr' value='$nr' >";
?>
  <input type="hidden" name="tab" value="search" >
  <section id="inputs">
    <input type="text" name="smak" placeholder="Smak på pölse" required>
    <select name="fabrik" id="fabrik">
      <option value="-1">-- Fabrik --</option>
      <?php

        $fabriker = selectAllFromTable("Fabrik");

        foreach($fabriker as $fabrik) {
          $namn = $fabrik["namn"];
          $id = $fabrik["id"];
          echo "<option value='$id'>$namn</option>";
        }
      ?>
    </select>
  </section>
  
  <button id="pensionera" type="submit">Pensionera</button>
</form>

<?php
  if (isset($_POST["nr"]) && isset($_POST["burknr"]) && isset($_POST["smak"]) && isset($_POST["fabrik"])) {
    try {
      $call = $pdo->prepare("CALL PensioneraRen(:nr, :burknr, :fabrik, :smak)");
      
      # Ankalla procedur
      $call->execute([
        ":nr" => $_POST["nr"],
        ":burknr" => $_POST["burknr"],
        ":fabrik" => $_POST["fabrik"],
        ":smak" => $_POST["smak"]
      ]);

      # Omdirigera användare
      header("Location: datadefinition.php?tab=search&search=$nr");

    } catch (PDOException $e) {
      unset($_POST);
      echo "error vid pensionerande av Ren: " . $e->getMessage();
    }
  }
?>

