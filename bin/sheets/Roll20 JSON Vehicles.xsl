<?xml version="1.0" encoding="utf-8"?>
<!-- ext:json -->
<!--
  Export Chummer 4 -> JSON "contrat v2" pour la feuille Roll20 Shadowrun 4e / importeur Roll20.
  Version VEHICULES / DRONES : un tableau JSON, un element par vehicule du personnage (type "vehicle"), pour creer des fiches PNJ vehicule. XSLT 1.0, sortie texte : le JSON est construit a la main.
  Utilisation : Fichier > Imprimer (Ctrl+P), choisir "Roll20 JSON", puis enregistrer le resultat.
  (Copie aussi possible dans bin/export pour Fichier > Exporter, mode Carriere uniquement.)
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="text" encoding="utf-8"/>

  <!-- Caracteres conserves dans les textes libres (tout le reste, dont les caracteres de controle, est supprime). -->
  <xsl:variable name="allowed"> !"#$%&amp;'()*+,-./0123456789:;&lt;=&gt;?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~&#9;&#10;&#13;&#160;¡¢£¤¥¦§¨©ª«¬­®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿŒœŠšŸŽž€‘’‚“”„…–—•™</xsl:variable>

  <xsl:variable name="bs">\</xsl:variable>
  <xsl:variable name="q">"</xsl:variable>

  <!-- ===== Utilitaires ===== -->
  <xsl:template name="replace">
    <xsl:param name="s"/><xsl:param name="from"/><xsl:param name="to"/>
    <xsl:choose>
      <xsl:when test="contains($s,$from)">
        <xsl:value-of select="substring-before($s,$from)"/><xsl:value-of select="$to"/>
        <xsl:call-template name="replace">
          <xsl:with-param name="s" select="substring-after($s,$from)"/>
          <xsl:with-param name="from" select="$from"/><xsl:with-param name="to" select="$to"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$s"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Chaine JSON (avec guillemets) -->
  <xsl:template name="str">
    <xsl:param name="v"/>
    <xsl:variable name="clean" select="translate($v, translate($v,$allowed,''), '')"/>
    <xsl:variable name="a"><xsl:call-template name="replace"><xsl:with-param name="s" select="$clean"/><xsl:with-param name="from" select="$bs"/><xsl:with-param name="to" select="concat($bs,$bs)"/></xsl:call-template></xsl:variable>
    <xsl:variable name="b"><xsl:call-template name="replace"><xsl:with-param name="s" select="string($a)"/><xsl:with-param name="from" select="$q"/><xsl:with-param name="to" select="concat($bs,$q)"/></xsl:call-template></xsl:variable>
    <xsl:variable name="c"><xsl:call-template name="replace"><xsl:with-param name="s" select="string($b)"/><xsl:with-param name="from" select="'&#13;'"/><xsl:with-param name="to" select="''"/></xsl:call-template></xsl:variable>
    <xsl:variable name="d"><xsl:call-template name="replace"><xsl:with-param name="s" select="string($c)"/><xsl:with-param name="from" select="'&#10;'"/><xsl:with-param name="to" select="concat($bs,'n')"/></xsl:call-template></xsl:variable>
    <xsl:variable name="e"><xsl:call-template name="replace"><xsl:with-param name="s" select="string($d)"/><xsl:with-param name="from" select="'&#9;'"/><xsl:with-param name="to" select="concat($bs,'t')"/></xsl:call-template></xsl:variable>
    <xsl:value-of select="$q"/><xsl:value-of select="string($e)"/><xsl:value-of select="$q"/>
  </xsl:template>

  <!-- Nombre JSON : virgule decimale -> point ; sinon null -->
  <xsl:template name="num">
    <xsl:param name="v"/>
    <xsl:variable name="x" select="translate(normalize-space($v),',','.')"/>
    <xsl:choose>
      <xsl:when test="$x != '' and string(number($x)) != 'NaN'"><xsl:value-of select="number($x)"/></xsl:when>
      <xsl:otherwise>null</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Entier avec separateur de milliers (1,250) -->
  <xsl:template name="int">
    <xsl:param name="v"/>
    <xsl:call-template name="num"><xsl:with-param name="v" select="translate(normalize-space($v),',. ','')"/></xsl:call-template>
  </xsl:template>
  <!-- Entier de tete ("4 (17)" -> 4) -->
  <xsl:template name="lead">
    <xsl:param name="v"/>
    <xsl:variable name="n" select="normalize-space($v)"/>
    <xsl:call-template name="num"><xsl:with-param name="v" select="substring-before(concat($n,' '),' ')"/></xsl:call-template>
  </xsl:template>
  <xsl:template name="bool">
    <xsl:param name="v"/>
    <xsl:choose><xsl:when test="normalize-space($v)='True'">true</xsl:when><xsl:otherwise>false</xsl:otherwise></xsl:choose>
  </xsl:template>

  <!-- "cle":valeur -->
  <xsl:template name="kstr"><xsl:param name="k"/><xsl:param name="v"/>"<xsl:value-of select="$k"/>":<xsl:call-template name="str"><xsl:with-param name="v" select="$v"/></xsl:call-template></xsl:template>
  <xsl:template name="knum"><xsl:param name="k"/><xsl:param name="v"/>"<xsl:value-of select="$k"/>":<xsl:call-template name="num"><xsl:with-param name="v" select="$v"/></xsl:call-template></xsl:template>
  <xsl:template name="kint"><xsl:param name="k"/><xsl:param name="v"/>"<xsl:value-of select="$k"/>":<xsl:call-template name="int"><xsl:with-param name="v" select="$v"/></xsl:call-template></xsl:template>
  <xsl:template name="kbool"><xsl:param name="k"/><xsl:param name="v"/>"<xsl:value-of select="$k"/>":<xsl:call-template name="bool"><xsl:with-param name="v" select="$v"/></xsl:call-template></xsl:template>

  <!-- ===== Attributs ===== -->
  <xsl:template name="attr">
    <xsl:param name="abbr"/><xsl:param name="key"/>
    <xsl:variable name="a" select="attributes/attribute[name=$abbr]"/>
    <xsl:variable name="base" select="translate($a/base,',','.')"/>
    <xsl:variable name="total" select="translate($a/total,',','.')"/>
    <xsl:call-template name="knum"><xsl:with-param name="k" select="$key"/><xsl:with-param name="v" select="$base"/></xsl:call-template>,
    <xsl:call-template name="knum"><xsl:with-param name="k" select="concat($key,'_modifier')"/><xsl:with-param name="v" select="number($total) - number($base)"/></xsl:call-template>
  </xsl:template>

  <!-- ===== Competence de l'arme (table categorie -> competence) ===== -->
  <xsl:template name="weaponskill">
    <xsl:param name="cat"/>
    <xsl:choose>
      <xsl:when test="$cat='Bows' or $cat='Crossbows'">Archery</xsl:when>
      <xsl:when test="$cat='Assault Rifles' or $cat='Machine Pistols' or $cat='Submachine Guns' or $cat='Battle Rifles'">Automatics</xsl:when>
      <xsl:when test="$cat='Blades' or $cat='Cyberware Blades'">Blades</xsl:when>
      <xsl:when test="$cat='Clubs'">Clubs</xsl:when>
      <xsl:when test="$cat='Exotic Melee Weapons' or $cat='Cyberware Exotic Melee Weapons'">Exotic Melee Weapon</xsl:when>
      <xsl:when test="$cat='Flamethrowers'">Flamethrowers</xsl:when>
      <xsl:when test="$cat='Laser Weapons'">Laser Weapons</xsl:when>
      <xsl:when test="$cat='Exotic Ranged Weapons' or starts-with($cat,'Cyberware Hold') or $cat='Cyberware Light Pistols' or $cat='Cyberware Heavy Pistols' or $cat='Cyberware Machine Pistols' or $cat='Cyberware Submachine Guns' or $cat='Cyberware Shotguns' or $cat='Cyberware Grenade Launchers' or $cat='Cyberware Tasers' or $cat='Cyberware Exotic Ranged Weapons'">Exotic Ranged Weapon</xsl:when>
      <xsl:when test="$cat='Assault Cannons' or $cat='Grenade Launchers' or $cat='Missile Launchers' or $cat='Mortar Launchers' or $cat='Light Machine Guns' or $cat='Medium Machine Guns' or $cat='Heavy Machine Guns'">Heavy Weapons</xsl:when>
      <xsl:when test="$cat='Shotguns' or $cat='Sniper Rifles' or $cat='Sports Rifles'">Longarms</xsl:when>
      <xsl:when test="$cat='Throwing Weapons' or $cat='Cyberware Throwing Weapons'">Throwing Weapons</xsl:when>
      <xsl:when test="$cat='Unarmed' or $cat='Cyberware Clubs' or $cat='Cyberware'">Unarmed Combat</xsl:when>
      <xsl:otherwise>Pistols</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ===== Arme (aussi appelee pour l'arme sous le canon) ===== -->
  <xsl:template match="weapon">
    <xsl:variable name="cat" select="category_english"/>
    <xsl:variable name="wname" select="name_english"/>
    <xsl:variable name="sk"><xsl:call-template name="weaponskill"><xsl:with-param name="cat" select="$cat"/></xsl:call-template></xsl:variable>
    <xsl:variable name="skill" select="string($sk)"/>
    <xsl:variable name="exotic" select="starts-with($skill,'Exotic')"/>
    <xsl:variable name="chars" select="ancestor::character[1]"/>
    <xsl:variable name="found" select="($chars/skills/skill[not(knowledge='True') and ((name=$skill) or ($exotic and starts-with(name,$skill) and (contains(name,$wname) or spec=$wname)))])[1]"/>
    <xsl:variable name="dice" select="translate(dicepool,',','.')"/>
    {<xsl:call-template name="kstr"><xsl:with-param name="k" select="'name'"/><xsl:with-param name="v" select="name_english"/></xsl:call-template>,
    <xsl:call-template name="kstr"><xsl:with-param name="k" select="'custom_name'"/><xsl:with-param name="v" select="weaponname"/></xsl:call-template>,
    <xsl:call-template name="kstr"><xsl:with-param name="k" select="'category'"/><xsl:with-param name="v" select="$cat"/></xsl:call-template>,
    <xsl:call-template name="kstr"><xsl:with-param name="k" select="'type'"/><xsl:with-param name="v" select="type"/></xsl:call-template>,
    <xsl:call-template name="kstr"><xsl:with-param name="k" select="'skill'"/><xsl:with-param name="v" select="$skill"/></xsl:call-template>,
    <xsl:if test="$exotic"><xsl:call-template name="kstr"><xsl:with-param name="k" select="'skill_specialization'"/><xsl:with-param name="v" select="$wname"/></xsl:call-template>,
    </xsl:if>
    <xsl:call-template name="knum"><xsl:with-param name="k" select="'dice'"/><xsl:with-param name="v" select="$dice"/></xsl:call-template>,
    "dicepool_modifier":<xsl:choose>
      <xsl:when test="$cat != 'Gear' and $found and string(number($dice)) != 'NaN' and string(number(translate($found/total,',','.'))) != 'NaN'"><xsl:value-of select="number($dice) - number(translate($found/total,',','.'))"/></xsl:when>
      <xsl:otherwise>null</xsl:otherwise>
    </xsl:choose>,
    <xsl:call-template name="kstr"><xsl:with-param name="k" select="'dv'"/><xsl:with-param name="v" select="damage_english"/></xsl:call-template>,
    <xsl:call-template name="kstr"><xsl:with-param name="k" select="'ap'"/><xsl:with-param name="v" select="ap"/></xsl:call-template>,
    <xsl:call-template name="kstr"><xsl:with-param name="k" select="'mode'"/><xsl:with-param name="v" select="mode"/></xsl:call-template>,
    <xsl:call-template name="kstr"><xsl:with-param name="k" select="'recoil'"/><xsl:with-param name="v" select="rc"/></xsl:call-template>,
    <xsl:call-template name="kstr"><xsl:with-param name="k" select="'ammo'"/><xsl:with-param name="v" select="ammo_english"/></xsl:call-template>,
    <xsl:call-template name="kstr"><xsl:with-param name="k" select="'reach'"/><xsl:with-param name="v" select="reach"/></xsl:call-template>,
    <xsl:call-template name="kstr"><xsl:with-param name="k" select="'note'"/><xsl:with-param name="v" select="notes"/></xsl:call-template>,
    "ranges":{<xsl:call-template name="kstr"><xsl:with-param name="k" select="'short'"/><xsl:with-param name="v" select="ranges/short"/></xsl:call-template>,
      <xsl:call-template name="kstr"><xsl:with-param name="k" select="'medium'"/><xsl:with-param name="v" select="ranges/medium"/></xsl:call-template>,
      <xsl:call-template name="kstr"><xsl:with-param name="k" select="'long'"/><xsl:with-param name="v" select="ranges/long"/></xsl:call-template>,
      <xsl:call-template name="kstr"><xsl:with-param name="k" select="'extreme'"/><xsl:with-param name="v" select="ranges/extreme"/></xsl:call-template>},
    "accessories":[<xsl:for-each select="accessories/accessory"><xsl:if test="position()>1">,</xsl:if>{<xsl:call-template name="kstr"><xsl:with-param name="k" select="'name'"/><xsl:with-param name="v" select="name"/></xsl:call-template>,<xsl:call-template name="kstr"><xsl:with-param name="k" select="'mount'"/><xsl:with-param name="v" select="mount"/></xsl:call-template>,<xsl:call-template name="kstr"><xsl:with-param name="k" select="'rc'"/><xsl:with-param name="v" select="rc"/></xsl:call-template>}</xsl:for-each>],
    "mods":[<xsl:for-each select="mods/weaponmod"><xsl:if test="position()>1">,</xsl:if>{<xsl:call-template name="kstr"><xsl:with-param name="k" select="'name'"/><xsl:with-param name="v" select="name"/></xsl:call-template>,<xsl:call-template name="knum"><xsl:with-param name="k" select="'rating'"/><xsl:with-param name="v" select="rating"/></xsl:call-template>}</xsl:for-each>],
    "underbarrel":[<xsl:for-each select="underbarrel/weapon"><xsl:if test="position()>1">,</xsl:if><xsl:apply-templates select="."/></xsl:for-each>]}
  </xsl:template>


  <!-- ===== Vehicule / drone ===== -->
  <xsl:template match="vehicle">
    <xsl:variable name="alias"><xsl:choose><xsl:when test="normalize-space(vehiclename) != ''"><xsl:value-of select="vehiclename"/></xsl:when><xsl:otherwise><xsl:value-of select="name"/></xsl:otherwise></xsl:choose></xsl:variable>
    <xsl:variable name="acc"><xsl:choose><xsl:when test="contains(accel,'/')"><xsl:value-of select="substring-before(accel,'/')"/></xsl:when><xsl:otherwise><xsl:value-of select="accel"/></xsl:otherwise></xsl:choose></xsl:variable>
    {"type":"vehicle",
    <xsl:call-template name="kstr"><xsl:with-param name="k" select="'name'"/><xsl:with-param name="v" select="$alias"/></xsl:call-template>,
    <xsl:call-template name="kstr"><xsl:with-param name="k" select="'model'"/><xsl:with-param name="v" select="name"/></xsl:call-template>,
    <xsl:call-template name="kstr"><xsl:with-param name="k" select="'category'"/><xsl:with-param name="v" select="category"/></xsl:call-template>,
    <xsl:call-template name="kbool"><xsl:with-param name="k" select="'drone'"/><xsl:with-param name="v" select="substring('True',1,4*number(starts-with(category,'Drones')))"/></xsl:call-template>,
    <xsl:call-template name="knum"><xsl:with-param name="k" select="'handling'"/><xsl:with-param name="v" select="handling"/></xsl:call-template>,
    <xsl:call-template name="kstr"><xsl:with-param name="k" select="'accel'"/><xsl:with-param name="v" select="accel"/></xsl:call-template>,
    <xsl:call-template name="knum"><xsl:with-param name="k" select="'acceleration'"/><xsl:with-param name="v" select="$acc"/></xsl:call-template>,
    <xsl:call-template name="knum"><xsl:with-param name="k" select="'speed'"/><xsl:with-param name="v" select="speed"/></xsl:call-template>,
    <xsl:call-template name="knum"><xsl:with-param name="k" select="'pilot'"/><xsl:with-param name="v" select="pilot"/></xsl:call-template>,
    <xsl:call-template name="knum"><xsl:with-param name="k" select="'body'"/><xsl:with-param name="v" select="body"/></xsl:call-template>,
    <xsl:call-template name="knum"><xsl:with-param name="k" select="'armor'"/><xsl:with-param name="v" select="armor"/></xsl:call-template>,
    <xsl:call-template name="knum"><xsl:with-param name="k" select="'sensor'"/><xsl:with-param name="v" select="sensor"/></xsl:call-template>,
    <xsl:call-template name="knum"><xsl:with-param name="k" select="'sensor_signal'"/><xsl:with-param name="v" select="sensorsignal"/></xsl:call-template>,
    <xsl:call-template name="knum"><xsl:with-param name="k" select="'response'"/><xsl:with-param name="v" select="response"/></xsl:call-template>,
    <xsl:call-template name="knum"><xsl:with-param name="k" select="'system'"/><xsl:with-param name="v" select="system"/></xsl:call-template>,
    <xsl:call-template name="knum"><xsl:with-param name="k" select="'signal'"/><xsl:with-param name="v" select="signal"/></xsl:call-template>,
    <xsl:call-template name="knum"><xsl:with-param name="k" select="'firewall'"/><xsl:with-param name="v" select="firewall"/></xsl:call-template>,
    <xsl:call-template name="knum"><xsl:with-param name="k" select="'device_rating'"/><xsl:with-param name="v" select="devicerating"/></xsl:call-template>,
    <xsl:call-template name="knum"><xsl:with-param name="k" select="'physical_max'"/><xsl:with-param name="v" select="physicalcm"/></xsl:call-template>,
    <xsl:call-template name="knum"><xsl:with-param name="k" select="'physical_damage'"/><xsl:with-param name="v" select="physicalcmfilled"/></xsl:call-template>,
    <xsl:call-template name="kint"><xsl:with-param name="k" select="'cost'"/><xsl:with-param name="v" select="cost"/></xsl:call-template>,
    <xsl:call-template name="kstr"><xsl:with-param name="k" select="'source'"/><xsl:with-param name="v" select="source"/></xsl:call-template>,
    "mods":[<xsl:for-each select="mods/mod"><xsl:if test="position()>1">,</xsl:if>{<xsl:call-template name="kstr"><xsl:with-param name="k" select="'name'"/><xsl:with-param name="v" select="name"/></xsl:call-template>,<xsl:call-template name="kstr"><xsl:with-param name="k" select="'category'"/><xsl:with-param name="v" select="category"/></xsl:call-template>,<xsl:call-template name="knum"><xsl:with-param name="k" select="'slots'"/><xsl:with-param name="v" select="slots"/></xsl:call-template>,<xsl:call-template name="knum"><xsl:with-param name="k" select="'rating'"/><xsl:with-param name="v" select="rating"/></xsl:call-template>,<xsl:call-template name="kstr"><xsl:with-param name="k" select="'limit'"/><xsl:with-param name="v" select="limit"/></xsl:call-template>,<xsl:call-template name="kbool"><xsl:with-param name="k" select="'included'"/><xsl:with-param name="v" select="included"/></xsl:call-template>}</xsl:for-each>],
    "weapons":[<xsl:for-each select="weapons/weapon | mods/mod/weapons/weapon"><xsl:if test="position()>1">,</xsl:if><xsl:apply-templates select="."/></xsl:for-each>],
    "gear":[<xsl:for-each select="gears//gear"><xsl:if test="position()>1">,</xsl:if>{<xsl:call-template name="kstr"><xsl:with-param name="k" select="'name'"/><xsl:with-param name="v" select="name_english"/></xsl:call-template>,<xsl:call-template name="kstr"><xsl:with-param name="k" select="'category'"/><xsl:with-param name="v" select="category_english"/></xsl:call-template>,<xsl:call-template name="knum"><xsl:with-param name="k" select="'rating'"/><xsl:with-param name="v" select="rating"/></xsl:call-template>,<xsl:call-template name="knum"><xsl:with-param name="k" select="'quantity'"/><xsl:with-param name="v" select="qty"/></xsl:call-template>,<xsl:call-template name="kstr"><xsl:with-param name="k" select="'extra'"/><xsl:with-param name="v" select="extra"/></xsl:call-template>,<xsl:call-template name="kstr"><xsl:with-param name="k" select="'parent'"/><xsl:with-param name="v" select="ancestor::gear[1]/name_english"/></xsl:call-template>}</xsl:for-each>]}
  </xsl:template>

  <!-- ===== Document ===== -->
  <xsl:template match="/characters/character">[<xsl:for-each select="vehicles/vehicle"><xsl:if test="position()>1">,</xsl:if><xsl:apply-templates select="."/></xsl:for-each>]</xsl:template>
  <xsl:template match="/characters"><xsl:apply-templates select="character[1]"/></xsl:template>
  <xsl:template match="text()"/>
</xsl:stylesheet>
