<?php
array_map('unlink', glob(__DIR__ . '/backend/writable/cache/*'));
echo "Cache cleared.\n";
