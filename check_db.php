<?php
if (extension_loaded('pgsql')) {
    echo "pgsql is enabled.\n";
} else {
    echo "pgsql is NOT enabled.\n";
}
if (extension_loaded('pdo_pgsql')) {
    echo "pdo_pgsql is enabled.\n";
} else {
    echo "pdo_pgsql is NOT enabled.\n";
}
if (extension_loaded('mysqli')) {
    echo "mysqli is enabled.\n";
}
