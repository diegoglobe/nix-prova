<?php
// Configurazione minima per phpMyAdmin
$cfg['blowfish_secret'] = 'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4'; // Chiave casuale
$i = 0;

// Configurazione Server
$i++;
$cfg['Servers'][$i]['auth_type'] = 'cookie';
$cfg['Servers'][$i]['host'] = '127.0.0.1';
$cfg['Servers'][$i]['port'] = '3306'; // Porta di default di MariaDB
$cfg['Servers'][$i]['compress'] = false;
$cfg['Servers'][$i]['AllowNoPassword'] = true; // Permette all'utente root di loggarsi
?>
