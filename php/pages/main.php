<div class="main">
  <div id="tables">
		<?php
      # Hämta PDO instance
      require "./pdo.php";

      $renar = selectAllFromTable("Ren");
      createTable($renar);

      $spann = selectAllFromTable("Spann");
      createTable($spann);
		?>
	</div>
</div>