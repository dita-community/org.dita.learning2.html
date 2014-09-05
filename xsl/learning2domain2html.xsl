<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="xs xd"
  version="2.0">
  <!-- ========================================================
        Learning 2 Domain (questions and answers) HTML generation.
        
        Provides base support for generating HTML from learning2
        interactions.
  
  ======================================================== -->
  
  <xsl:template match="*[contains(@class, ' learning2-d/lcTrueFalse2 ')]">
    <xsl:next-match/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' learning2-d/lcSingleSelect2 ')]">
    <xsl:next-match/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' learning2-d/lcMultipleSelect2 ')]">
    <xsl:next-match/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' learning2-d/lcSequencing2 ')]">
    <xsl:next-match/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' learning2-d/lcMatching2 ')]">
    <xsl:next-match/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' learning2-d/lcHotspot2 ')]">
    <xsl:next-match/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' learning2-d/lcOpenQuestion2 ')]">
    <xsl:next-match/>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' learningInteractionBase2-d/lcInteractionBase2 ')]"
      priority="-0.5"
    >
    <!-- Fallback handling for interactions -->
    <div>
      <xsl:call-template name="commonattributes"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
</xsl:stylesheet>