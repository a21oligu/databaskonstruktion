<div id="search">
  <form id="search-form" action="./datadefinition.php?tab='search'" method="get">
    <input type="text" name="search" id="search-input" placeholder="Sök Ren med nummer">
    <select name="spann" id="spann">
      <option value="-1">-- Välj spann --</option>
      <?php
        require "pdo.php";

        $spann = selectAllFromTable("Spann");

        foreach($spann as $s) {
          $namn = $s["namn"];
          echo "<option value='$namn'>$namn</option>";
        }
      ?>
        
    </select>
    <input type="hidden" name="tab" value="search" >
    <button type="submit">sök</button>
  </form>
  <?php
    if(isset($_GET["search"])) {
      $nr = $_GET["search"];
      $sp = isset($_GET["spann"]) ? $_GET["spann"] : -1;
      $get_renar_like_nr = "SELECT * FROM Ren WHERE nr LIKE '%$nr%'" . ($sp != -1 ? " AND spann = '$sp'" : "");
      $stmt = $pdo->prepare($get_renar_like_nr, array(PDO::FETCH_ASSOC));
      $stmt->execute();

      $renar = $stmt->fetchAll(PDO::FETCH_ASSOC);

      $form = array("action" => "datadefinition.php?tab=_pensionera", "key" => "nr", "method" => "POST", "text" => "pensionera");
      echo count($renar) > 0 ? createTable($renar, $form) : "<h3>Inga renar hittades!</h3>";
    } else {
      echo "<h3>Ingen data att visa, testa söka</h3>";
    }
  ?>
</div>