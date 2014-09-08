<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="xs xd"
  version="2.0">
  <!-- ========================================================
        Learning Domain (questions and answers) HTML generation.
        
        Provides base support for generating HTML from the 
        learning1 (DITA 1.2) and learning2 (DITA 1.3)
        interactions.
        
        For CSS purposes this code uses the learning1 names,
        in addition to the learning2 names, in the generated
        HTML @class attributes.
  
        Extension points:
        
        - The named template lcGetQuestionNumber generates the numbers
          for questions and implements the lc-number-questions
          parameter. You can extend or override this template to
          control how numbers are generated and formatted.
          
        
  
  ======================================================== -->
  
  <!-- Control how questions are numbered. Values are:
    
       - true/yes/on/1  : Number questions sequentially within the scope of
         their direct parent container. This is the default. Same as
         "within-parent" option.
         
       - false/no/off/0  : Do not number questions.
         
       - within-parent  : Number the questions sequentially within the scope
         of their direct parent container.
         
       - within-topic   : Number the questions sequentially within the scope
         of the topic that contains them.
         
       - within-chapter : Number the questions sequentially within the scope
         of the top-level topic ("chapter") that contains them. Bookmap and
         pubmap part topics do not count as chapters.
         
       - within-publication: Number the questions sequentially through
         the entire publication.
         
   -->
  <xsl:param name="lc-number-questions" as="xs:string" select="'true'"/>
  <xsl:variable name="lcNumberQuestions"></xsl:variable>
  
  <!-- Default format string to use for generating question numbers. This
       value will be used by the xsl:number @format attribute.
    -->
  <xsl:param name="lc-question-number-format" as="xs:string" select="'1.'"/>
  <!-- Static prefix to put before question numbers. Default is "Q ". -->
  <xsl:param name="lc-question-number-prefix" as="xs:string" select="'Q '"/>
  <!-- Static suffix to put after question numbers. Default is " " (Single space). -->
  <xsl:param name="lc-question-number-suffix" as="xs:string" select="' '"/>
  
  <xsl:include href="plugin:org.dita.dita13base.html:xsl/dita13base2html.xsl"/>
  
  <!-- =====================
       True/False
       ===================== -->
  
  <xsl:template match="*[contains(@class, ' learning2-d/lcTrueFalse2 ')]">
    <div class="lcTrueFalse {name(.)}">
      <xsl:call-template name="commonattributes"/>
      <xsl:call-template name="lc-setClassAtt">
        <xsl:with-param name="baseClass" select="'lcTrueFalse'" as="xs:string"/>
      </xsl:call-template>
      <xsl:apply-templates 
        select="*[contains(@class, ' learningInteractionBase2-d/lcQuestionBase2 ')]"
      />
      <xsl:apply-templates 
        select="*[contains(@class, ' learning2-d/lcAnswerOptionGroup2 ')]"
      />
    </div>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' learning2-d/lcTrueFalse2 ')]/*[contains(@class, ' learningInteractionBase2-d/lcQuestionBase2 ')]">
    <div>
      <xsl:call-template name="lc-setClassAtt">
        <xsl:with-param name="baseClass" select="'lcTrueFalseQuestion'" as="xs:string"/>
      </xsl:call-template>
      <xsl:call-template name="lcGetQuestionNumber"/>
      <span class="lcQuestionText"><xsl:apply-templates/></span>
    </div>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' learning2-d/lcTrueFalse2 ')]/*[contains(@class, ' learning2-d/lcAnswerOptionGroup2 ')]">
    <div class="lcTrueFalseAnswers {name(.)} lcAnswerOptionGroup">
      <xsl:apply-templates/>
    </div>
  </xsl:template>
   
   
  <!-- There are several different ways commonly used to present true/false questions:
    
        T   F     1. This is the question
        
        
        1. This is the question
           
           A. True
           B. False
           
        1. This is the question (T/F is not reflected anywhere, maybe because there's a separate answer sheet)
        
        For simplicity, using the second form, which makes it the same as single and multiple-select 
        questions.
     -->
  
  <!-- =====================
       Single Select
       ===================== -->
  
  <xsl:template match="*[contains(@class, ' learning2-d/lcSingleSelect2 ')]">
    <div>
      <xsl:call-template name="commonattributes"/>
      <xsl:call-template name="lc-setClassAtt">
        <xsl:with-param name="baseClass" select="'lcSingleSelect'" as="xs:string"/>
      </xsl:call-template>
      <xsl:apply-templates 
        select="*[contains(@class, ' learningInteractionBase2-d/lcQuestionBase2 ')]"
      />
      <xsl:apply-templates 
        select="*[contains(@class, ' learning2-d/lcAnswerOptionGroup2 ')]"
      />
    </div>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' learning2-d/lcSingleSelect2 ')]/*[contains(@class, ' learningInteractionBase2-d/lcQuestionBase2 ')]">
    <div>
      <xsl:call-template name="lc-setClassAtt">
        <xsl:with-param name="baseClass" select="'lcSingleSelectQuestion'" as="xs:string"/>
      </xsl:call-template>
      <xsl:call-template name="lcGetQuestionNumber"/>
      <span class="lcQuestionText"><xsl:apply-templates/></span>
    </div>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' learning2-d/lcSingleSelect2 ')]/*[contains(@class, ' learning2-d/lcAnswerOptionGroup2 ')]">
    <div>
      <xsl:call-template name="lc-setClassAtt">
        <xsl:with-param name="baseClass" select="'lcSingleSelectAnswers lcAnswerOptionGroup'" as="xs:string"/>
      </xsl:call-template>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
   
  
  <!-- =====================
       Multiple Select
       ===================== -->
  
  <xsl:template match="*[contains(@class, ' learning2-d/lcMultipleSelect2 ')]">
    <xsl:next-match/>
  </xsl:template>
  
  <!-- =====================
       Sequencing
       ===================== -->

  <xsl:template match="*[contains(@class, ' learning2-d/lcSequencing2 ')]">
    <xsl:next-match/>
  </xsl:template>
  
  <!-- =====================
       Matching
       ===================== -->
  <xsl:template match="*[contains(@class, ' learning2-d/lcMatching2 ')]">
    <xsl:next-match/>
  </xsl:template>
  
  <!-- =====================
       Hotspot
       ===================== -->
  <xsl:template match="*[contains(@class, ' learning2-d/lcHotspot2 ')]">
    <xsl:next-match/>
  </xsl:template>
  
  <!-- =====================
       Open question
       ===================== -->
  <xsl:template match="*[contains(@class, ' learning2-d/lcOpenQuestion2 ')]">
    <xsl:message> + [DEBUG] learning2-d/lcOpenQuestion2</xsl:message>
    <xsl:next-match/>
  </xsl:template>
  
  <!-- =====================
       Fallback handling
       ===================== -->
  <xsl:template match="*[contains(@class, ' learningInteractionBase2-d/lcInteractionBase2 ')]"
      priority="-0.5"
    >
    <xsl:message> + [DEBUG] learningInteractionBase2-d/lcInteractionBase2: <xsl:value-of select="concat(name(..), '/', name(.))"/></xsl:message>
    <!-- Fallback handling for interactions -->
    <div>
      <xsl:call-template name="commonattributes"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  <!-- ====================================================
       General interaction support templates and functions.
       ==================================================== -->
       
  <xsl:template name="lc-setClassAtt">
    <xsl:param name="baseClass" select="''" as="xs:string"/>
    <xsl:variable name="classAtt" as="attribute()">
      <xsl:apply-templates select="." mode="set-output-class"/>      
    </xsl:variable>
    <xsl:attribute name="class" select="($baseClass, string($classAtt))"/>
  </xsl:template>     
       
  <xsl:template name="lcGetQuestionNumber">
    <!-- Generates the question number. Note that without
         map-driven processing some of the possible options
         cannot be implemented using XSLT alone.
      -->
    <xsl:param name="numberFormat" as="xs:string" select="$lc-question-number-format"/>
    <xsl:variable name="questionNumber" as="xs:string">
      <xsl:choose>
        <xsl:when test="matches($lc-number-questions, 'no|false|off|0', 'i')">
          <xsl:sequence select="''"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:number 
            count="*[contains(@class, ' learningInteractionBase2-d/lcInteractionBase2 ')]"
            format="{$numberFormat}"
          />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$questionNumber != ''">
      <span class="lcQuestionNumber">
        <xsl:value-of select="$lc-question-number-prefix"/>
        <xsl:value-of select="$questionNumber"/>
        <xsl:value-of select="$lc-question-number-suffix"/>
      </span>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>