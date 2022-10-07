<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>PHP a21oligu</title>
	<link rel="stylesheet" href="./style.css">
</head>
<body>
	<main>
		<section id="sidemenu">
			<h3>a21oligu datadefinition</h3>
				<?php
					$pages = scandir("pages");
					$skip_pages = array(".", "..");
					foreach($pages as $page) {
						# Fortsätt om sidan ej ska länkas
						if (in_array($page, $skip_pages) || $page[0] == "_") continue;

						# Ta bort .php fran filnamn
						$page_name = str_replace(".php", "", $page);
						// $display_name = explode("_", $page_name);
						$tab = isset($_GET["tab"]) ? $_GET["tab"] : false;
						
						$active = $tab == $page_name ? "active": "";
						
						echo "<a class='sidemenu-item $active'  href='datadefinition.php?tab=$page_name'>$page_name</a>";
					}
				?>
		</section>
		<section id="content">
			<?php
				if (isset($_GET["tab"])){
					$tab = $_GET["tab"];
					$file = "pages/$tab.php";
					if (is_readable($file)) {
						require $file;
					} else {
						echo "Can not read this php file...";
					}
				} else {
					echo "<h3>Använd sidomeny för att navigera</h3>";
				}
			?>
		</section>
	</main>
</body>
</html>
