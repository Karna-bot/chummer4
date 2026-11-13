<?xml version="1.0" encoding="utf-8"?>
<!-- ext:json -->
<!--
  Export Chummer 4 -> JSON "contrat v2" pour la feuille Roll20 Shadowrun 4e / importeur Roll20.
  Version PJ (type "pc"). XSLT 1.0, sortie texte : le JSON est construit a la main.
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
  <xsl:template match="/characters/character">
    <xsl:variable name="alias" select="normalize-space(alias)"/>
    <xsl:variable name="dispname">
      <xsl:choose>
        <xsl:when test="$alias != ''"><xsl:value-of select="$alias"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="name"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
{
"contract":"2",
"type":"pc",
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'name'"/><xsl:with-param name="v" select="string($dispname)"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'real_name'"/><xsl:with-param name="v" select="name"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'alias'"/><xsl:with-param name="v" select="alias"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'player_name'"/><xsl:with-param name="v" select="playername"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'metatype'"/><xsl:with-param name="v" select="concat(metatype_english, substring(concat(' (',metavariant_english,')'), 1 div (normalize-space(metavariant_english) != '')))"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'sex'"/><xsl:with-param name="v" select="sex"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'age'"/><xsl:with-param name="v" select="age"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'height'"/><xsl:with-param name="v" select="height"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'weight'"/><xsl:with-param name="v" select="weight"/></xsl:call-template>,
<xsl:call-template name="kint"><xsl:with-param name="k" select="'karma'"/><xsl:with-param name="v" select="karma"/></xsl:call-template>,
<xsl:call-template name="kint"><xsl:with-param name="k" select="'total_karma'"/><xsl:with-param name="v" select="totalkarma"/></xsl:call-template>,
<xsl:call-template name="kint"><xsl:with-param name="k" select="'street_cred'"/><xsl:with-param name="v" select="totalstreetcred"/></xsl:call-template>,
<xsl:call-template name="kint"><xsl:with-param name="k" select="'notoriety'"/><xsl:with-param name="v" select="totalnotoriety"/></xsl:call-template>,
<xsl:call-template name="kint"><xsl:with-param name="k" select="'public_awareness'"/><xsl:with-param name="v" select="totalpublicawareness"/></xsl:call-template>,
<xsl:call-template name="kint"><xsl:with-param name="k" select="'nuyen'"/><xsl:with-param name="v" select="nuyen"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'concept'"/><xsl:with-param name="v" select="concept"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'description'"/><xsl:with-param name="v" select="description"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'background'"/><xsl:with-param name="v" select="background"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'notes'"/><xsl:with-param name="v" select="notes"/></xsl:call-template>,
"flag_special":"<xsl:choose><xsl:when test="technomancer='True' or resenabled='True'">resonance</xsl:when><xsl:when test="magician='True' or adept='True' or magenabled='True'">magic</xsl:when><xsl:otherwise>mundane</xsl:otherwise></xsl:choose>",
<xsl:call-template name="kbool"><xsl:with-param name="k" select="'adept'"/><xsl:with-param name="v" select="adept"/></xsl:call-template>,
<xsl:call-template name="kbool"><xsl:with-param name="k" select="'magician'"/><xsl:with-param name="v" select="magician"/></xsl:call-template>,
<xsl:call-template name="kbool"><xsl:with-param name="k" select="'technomancer'"/><xsl:with-param name="v" select="technomancer"/></xsl:call-template>,
"attributes":{
<xsl:call-template name="attr"><xsl:with-param name="abbr" select="'BOD'"/><xsl:with-param name="key" select="'body'"/></xsl:call-template>,
<xsl:call-template name="attr"><xsl:with-param name="abbr" select="'AGI'"/><xsl:with-param name="key" select="'agility'"/></xsl:call-template>,
<xsl:call-template name="attr"><xsl:with-param name="abbr" select="'REA'"/><xsl:with-param name="key" select="'reaction'"/></xsl:call-template>,
<xsl:call-template name="attr"><xsl:with-param name="abbr" select="'STR'"/><xsl:with-param name="key" select="'strength'"/></xsl:call-template>,
<xsl:call-template name="attr"><xsl:with-param name="abbr" select="'CHA'"/><xsl:with-param name="key" select="'charisma'"/></xsl:call-template>,
<xsl:call-template name="attr"><xsl:with-param name="abbr" select="'INT'"/><xsl:with-param name="key" select="'intuition'"/></xsl:call-template>,
<xsl:call-template name="attr"><xsl:with-param name="abbr" select="'LOG'"/><xsl:with-param name="key" select="'logic'"/></xsl:call-template>,
<xsl:call-template name="attr"><xsl:with-param name="abbr" select="'WIL'"/><xsl:with-param name="key" select="'willpower'"/></xsl:call-template>,
<xsl:call-template name="knum"><xsl:with-param name="k" select="'edge'"/><xsl:with-param name="v" select="attributes/attribute[name='EDG']/total"/></xsl:call-template>,
<xsl:call-template name="attr"><xsl:with-param name="abbr" select="'MAG'"/><xsl:with-param name="key" select="'magic'"/></xsl:call-template>,
<xsl:call-template name="attr"><xsl:with-param name="abbr" select="'RES'"/><xsl:with-param name="key" select="'resonance'"/></xsl:call-template>,
<xsl:call-template name="knum"><xsl:with-param name="k" select="'essence'"/><xsl:with-param name="v" select="attributes/attribute[name='ESS']/base"/></xsl:call-template>},
"derived":{
<xsl:call-template name="knum"><xsl:with-param name="k" select="'initiative'"/><xsl:with-param name="v" select="init/total"/></xsl:call-template>,
<xsl:call-template name="knum"><xsl:with-param name="k" select="'initiative_passes'"/><xsl:with-param name="v" select="ip/total"/></xsl:call-template>,
<xsl:call-template name="knum"><xsl:with-param name="k" select="'matrix_initiative'"/><xsl:with-param name="v" select="matrixinit/base"/></xsl:call-template>,
<xsl:call-template name="knum"><xsl:with-param name="k" select="'matrix_passes'"/><xsl:with-param name="v" select="matrixip/base"/></xsl:call-template>,
<xsl:call-template name="knum"><xsl:with-param name="k" select="'astral_initiative'"/><xsl:with-param name="v" select="astralinit/base"/></xsl:call-template>,
<xsl:call-template name="knum"><xsl:with-param name="k" select="'astral_passes'"/><xsl:with-param name="v" select="astralip/base"/></xsl:call-template>,
<xsl:call-template name="knum"><xsl:with-param name="k" select="'physical_max'"/><xsl:with-param name="v" select="physicalcm"/></xsl:call-template>,
<xsl:call-template name="knum"><xsl:with-param name="k" select="'stun_max'"/><xsl:with-param name="v" select="stuncm"/></xsl:call-template>,
<xsl:call-template name="knum"><xsl:with-param name="k" select="'physical_damage'"/><xsl:with-param name="v" select="physicalcmfilled"/></xsl:call-template>,
<xsl:call-template name="knum"><xsl:with-param name="k" select="'stun_damage'"/><xsl:with-param name="v" select="stuncmfilled"/></xsl:call-template>,
<xsl:call-template name="knum"><xsl:with-param name="k" select="'composure'"/><xsl:with-param name="v" select="composure"/></xsl:call-template>,
<xsl:call-template name="knum"><xsl:with-param name="k" select="'judge_intentions'"/><xsl:with-param name="v" select="judgeintentions"/></xsl:call-template>,
<xsl:call-template name="knum"><xsl:with-param name="k" select="'lift_carry'"/><xsl:with-param name="v" select="liftandcarry"/></xsl:call-template>,
<xsl:call-template name="knum"><xsl:with-param name="k" select="'memory'"/><xsl:with-param name="v" select="memory"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'movement'"/><xsl:with-param name="v" select="movement"/></xsl:call-template>,
<xsl:call-template name="knum"><xsl:with-param name="k" select="'armor_ballistic'"/><xsl:with-param name="v" select="armorb"/></xsl:call-template>,
<xsl:call-template name="knum"><xsl:with-param name="k" select="'armor_impact'"/><xsl:with-param name="v" select="armori"/></xsl:call-template>},
"armor":{<xsl:call-template name="knum"><xsl:with-param name="k" select="'ballistic'"/><xsl:with-param name="v" select="armorb"/></xsl:call-template>,<xsl:call-template name="knum"><xsl:with-param name="k" select="'impact'"/><xsl:with-param name="v" select="armori"/></xsl:call-template>},
"skills":[<xsl:for-each select="skills/skill"><xsl:if test="position()>1">,</xsl:if>
{<xsl:call-template name="kstr"><xsl:with-param name="k" select="'name'"/><xsl:with-param name="v" select="name"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'category'"/><xsl:with-param name="v" select="skillcategory_english"/></xsl:call-template>,
<xsl:call-template name="knum"><xsl:with-param name="k" select="'rating'"/><xsl:with-param name="v" select="rating"/></xsl:call-template>,
<xsl:call-template name="knum"><xsl:with-param name="k" select="'rating_modifier'"/><xsl:with-param name="v" select="ratingmod"/></xsl:call-template>,
<xsl:call-template name="knum"><xsl:with-param name="k" select="'dicepool_modifier'"/><xsl:with-param name="v" select="poolmod"/></xsl:call-template>,
<xsl:call-template name="knum"><xsl:with-param name="k" select="'total'"/><xsl:with-param name="v" select="total"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'attribute'"/><xsl:with-param name="v" select="attribute"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'specialization'"/><xsl:with-param name="v" select="spec"/></xsl:call-template>,
<xsl:call-template name="kbool"><xsl:with-param name="k" select="'knowledge'"/><xsl:with-param name="v" select="knowledge"/></xsl:call-template>,
<xsl:call-template name="kbool"><xsl:with-param name="k" select="'language'"/><xsl:with-param name="v" select="islanguage"/></xsl:call-template>,
<xsl:call-template name="kbool"><xsl:with-param name="k" select="'exotic'"/><xsl:with-param name="v" select="exotic"/></xsl:call-template>}</xsl:for-each>],
"weapons":[<xsl:for-each select="weapons/weapon"><xsl:if test="position()>1">,</xsl:if><xsl:apply-templates select="."/></xsl:for-each>],
"armors":[<xsl:for-each select="armors/armor"><xsl:if test="position()>1">,</xsl:if>
{<xsl:call-template name="kstr"><xsl:with-param name="k" select="'name'"/><xsl:with-param name="v" select="name_english"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'custom_name'"/><xsl:with-param name="v" select="armorname"/></xsl:call-template>,
<xsl:call-template name="knum"><xsl:with-param name="k" select="'ballistic'"/><xsl:with-param name="v" select="b"/></xsl:call-template>,
<xsl:call-template name="knum"><xsl:with-param name="k" select="'impact'"/><xsl:with-param name="v" select="i"/></xsl:call-template>,
<xsl:call-template name="kbool"><xsl:with-param name="k" select="'equipped'"/><xsl:with-param name="v" select="equipped"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'note'"/><xsl:with-param name="v" select="notes"/></xsl:call-template>}</xsl:for-each>],
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'tradition'"/><xsl:with-param name="v" select="tradition"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'stream'"/><xsl:with-param name="v" select="stream"/></xsl:call-template>,
<xsl:call-template name="knum"><xsl:with-param name="k" select="'initiate_grade'"/><xsl:with-param name="v" select="initiategrade"/></xsl:call-template>,
<xsl:call-template name="knum"><xsl:with-param name="k" select="'submersion'"/><xsl:with-param name="v" select="submersiongrade"/></xsl:call-template>,
"metamagics":[<xsl:for-each select="metamagics/metamagic"><xsl:if test="position()>1">,</xsl:if><xsl:call-template name="str"><xsl:with-param name="v" select="name"/></xsl:call-template></xsl:for-each>],
"spells":[<xsl:for-each select="spells/spell"><xsl:if test="position()>1">,</xsl:if>
<xsl:variable name="dv" select="translate(normalize-space(dv),' ','')"/>
<xsl:variable name="tail">
  <xsl:choose>
    <xsl:when test="contains($dv,')')"><xsl:value-of select="substring-after($dv,')')"/></xsl:when>
    <xsl:otherwise><xsl:value-of select="substring-after($dv,'F')"/></xsl:otherwise>
  </xsl:choose>
</xsl:variable>
{<xsl:call-template name="kstr"><xsl:with-param name="k" select="'name'"/><xsl:with-param name="v" select="name"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'category'"/><xsl:with-param name="v" select="category"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'descriptors'"/><xsl:with-param name="v" select="descriptors"/></xsl:call-template>,
"type":"<xsl:choose><xsl:when test="type='M'">Mana</xsl:when><xsl:when test="type='P'">Physical</xsl:when><xsl:otherwise><xsl:value-of select="type"/></xsl:otherwise></xsl:choose>",
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'range'"/><xsl:with-param name="v" select="range"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'damage'"/><xsl:with-param name="v" select="damage"/></xsl:call-template>,
"duration":"<xsl:choose><xsl:when test="duration='I'">Instant</xsl:when><xsl:when test="duration='S'">Sustained</xsl:when><xsl:when test="duration='P'">Permanent</xsl:when><xsl:otherwise><xsl:value-of select="duration"/></xsl:otherwise></xsl:choose>",
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'dv'"/><xsl:with-param name="v" select="dv"/></xsl:call-template>,
"drain":<xsl:choose>
  <xsl:when test="string($tail)=''">0</xsl:when>
  <xsl:when test="starts-with(string($tail),'+')"><xsl:call-template name="num"><xsl:with-param name="v" select="substring(string($tail),2)"/></xsl:call-template></xsl:when>
  <xsl:otherwise><xsl:call-template name="num"><xsl:with-param name="v" select="string($tail)"/></xsl:call-template></xsl:otherwise>
</xsl:choose>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'extra'"/><xsl:with-param name="v" select="extra"/></xsl:call-template>}</xsl:for-each>],
"adept_powers":[<xsl:for-each select="powers/power"><xsl:if test="position()>1">,</xsl:if>
{<xsl:call-template name="kstr"><xsl:with-param name="k" select="'name'"/><xsl:with-param name="v" select="name"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'extra'"/><xsl:with-param name="v" select="extra"/></xsl:call-template>,
<xsl:call-template name="knum"><xsl:with-param name="k" select="'rating'"/><xsl:with-param name="v" select="rating"/></xsl:call-template>,
<xsl:call-template name="knum"><xsl:with-param name="k" select="'points'"/><xsl:with-param name="v" select="totalpoints"/></xsl:call-template>}</xsl:for-each>],
"complex_forms":[<xsl:for-each select="techprograms/techprogram"><xsl:if test="position()>1">,</xsl:if>
{<xsl:call-template name="kstr"><xsl:with-param name="k" select="'name'"/><xsl:with-param name="v" select="name"/></xsl:call-template>,
<xsl:call-template name="knum"><xsl:with-param name="k" select="'rating'"/><xsl:with-param name="v" select="rating"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'skill'"/><xsl:with-param name="v" select="skill"/></xsl:call-template>}</xsl:for-each>],
"martial_arts":[<xsl:for-each select="martialarts/martialart"><xsl:if test="position()>1">,</xsl:if>
{<xsl:call-template name="kstr"><xsl:with-param name="k" select="'name'"/><xsl:with-param name="v" select="name"/></xsl:call-template>,
"techniques":[<xsl:for-each select="../../martialartmaneuvers/martialartmaneuver"><xsl:if test="position()>1">,</xsl:if><xsl:call-template name="str"><xsl:with-param name="v" select="name"/></xsl:call-template></xsl:for-each>]}</xsl:for-each>],
"augmentations":[<xsl:for-each select="cyberwares//cyberware"><xsl:if test="position()>1">,</xsl:if>
{<xsl:call-template name="kstr"><xsl:with-param name="k" select="'name'"/><xsl:with-param name="v" select="name"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'category'"/><xsl:with-param name="v" select="category"/></xsl:call-template>,
<xsl:call-template name="knum"><xsl:with-param name="k" select="'rating'"/><xsl:with-param name="v" select="rating"/></xsl:call-template>,
<xsl:call-template name="knum"><xsl:with-param name="k" select="'essence'"/><xsl:with-param name="v" select="ess"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'grade'"/><xsl:with-param name="v" select="grade"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'location'"/><xsl:with-param name="v" select="location"/></xsl:call-template>,
<xsl:call-template name="kbool"><xsl:with-param name="k" select="'bioware'"/><xsl:with-param name="v" select="substring('True', 1 div (improvementsource='Bioware'))"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'parent'"/><xsl:with-param name="v" select="ancestor::cyberware[1]/name"/></xsl:call-template>}</xsl:for-each>],
"qualities":[<xsl:for-each select="qualities/quality"><xsl:if test="position()>1">,</xsl:if>
{<xsl:call-template name="kstr"><xsl:with-param name="k" select="'name'"/><xsl:with-param name="v" select="name"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'extra'"/><xsl:with-param name="v" select="extra"/></xsl:call-template>,
"type":"<xsl:choose><xsl:when test="qualitytype_english='Positive'">P</xsl:when><xsl:otherwise>N</xsl:otherwise></xsl:choose>",
<xsl:call-template name="knum"><xsl:with-param name="k" select="'bp'"/><xsl:with-param name="v" select="bp"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'source'"/><xsl:with-param name="v" select="qualitysource"/></xsl:call-template>}</xsl:for-each>],
"contacts":[<xsl:for-each select="contacts/contact"><xsl:if test="position()>1">,</xsl:if>
{<xsl:call-template name="kstr"><xsl:with-param name="k" select="'name'"/><xsl:with-param name="v" select="name"/></xsl:call-template>,
<xsl:call-template name="klead"><xsl:with-param name="k" select="'connection'"/><xsl:with-param name="v" select="connection"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'connection_text'"/><xsl:with-param name="v" select="connection"/></xsl:call-template>,
<xsl:call-template name="knum"><xsl:with-param name="k" select="'loyalty'"/><xsl:with-param name="v" select="loyalty"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'type'"/><xsl:with-param name="v" select="type"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'notes'"/><xsl:with-param name="v" select="notes"/></xsl:call-template>}</xsl:for-each>],
"lifestyles":[<xsl:for-each select="lifestyles/lifestyle"><xsl:if test="position()>1">,</xsl:if>
{<xsl:call-template name="kstr"><xsl:with-param name="k" select="'name'"/><xsl:with-param name="v" select="lifestylename"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'lifestyle'"/><xsl:with-param name="v" select="name"/></xsl:call-template>,
<xsl:call-template name="knum"><xsl:with-param name="k" select="'months'"/><xsl:with-param name="v" select="months"/></xsl:call-template>,
<xsl:call-template name="kint"><xsl:with-param name="k" select="'cost'"/><xsl:with-param name="v" select="cost"/></xsl:call-template>}</xsl:for-each>],
"vehicles":[<xsl:for-each select="vehicles/vehicle"><xsl:if test="position()>1">,</xsl:if><xsl:apply-templates select="."/></xsl:for-each>],
"gear":[<xsl:for-each select="gears//gear"><xsl:if test="position()>1">,</xsl:if>
{<xsl:call-template name="kstr"><xsl:with-param name="k" select="'name'"/><xsl:with-param name="v" select="name_english"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'custom_name'"/><xsl:with-param name="v" select="gearname"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'category'"/><xsl:with-param name="v" select="category_english"/></xsl:call-template>,
<xsl:call-template name="knum"><xsl:with-param name="k" select="'rating'"/><xsl:with-param name="v" select="rating"/></xsl:call-template>,
<xsl:call-template name="knum"><xsl:with-param name="k" select="'quantity'"/><xsl:with-param name="v" select="qty"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'extra'"/><xsl:with-param name="v" select="extra"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'location'"/><xsl:with-param name="v" select="location"/></xsl:call-template>,
<xsl:call-template name="kstr"><xsl:with-param name="k" select="'parent'"/><xsl:with-param name="v" select="ancestor::gear[1]/name_english"/></xsl:call-template>,
<xsl:call-template name="kbool"><xsl:with-param name="k" select="'equipped'"/><xsl:with-param name="v" select="equipped"/></xsl:call-template>,
<xsl:call-template name="kbool"><xsl:with-param name="k" select="'commlink'"/><xsl:with-param name="v" select="iscommlink"/></xsl:call-template>,
<xsl:call-template name="kbool"><xsl:with-param name="k" select="'program'"/><xsl:with-param name="v" select="isprogram"/></xsl:call-template>,
<xsl:call-template name="kbool"><xsl:with-param name="k" select="'os'"/><xsl:with-param name="v" select="isos"/></xsl:call-template>,
<xsl:call-template name="knum"><xsl:with-param name="k" select="'response'"/><xsl:with-param name="v" select="response"/></xsl:call-template>,
<xsl:call-template name="knum"><xsl:with-param name="k" select="'signal'"/><xsl:with-param name="v" select="signal"/></xsl:call-template>,
<xsl:call-template name="knum"><xsl:with-param name="k" select="'system'"/><xsl:with-param name="v" select="system"/></xsl:call-template>,
<xsl:call-template name="knum"><xsl:with-param name="k" select="'firewall'"/><xsl:with-param name="v" select="firewall"/></xsl:call-template>}</xsl:for-each>]
}
  </xsl:template>

  <xsl:template name="klead"><xsl:param name="k"/><xsl:param name="v"/>"<xsl:value-of select="$k"/>":<xsl:call-template name="lead"><xsl:with-param name="v" select="$v"/></xsl:call-template></xsl:template>

  <xsl:template match="/characters">
    <xsl:apply-templates select="character[1]"/>
  </xsl:template>
  <xsl:template match="text()"/>
</xsl:stylesheet>
