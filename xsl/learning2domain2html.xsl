<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:lc="urn:function:learningContent"
  exclude-result-prefixes="xs xd lc"
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
  <xsl:variable name="lc:doNumberQuestions" as="xs:boolean" 
    select="matches($lc-number-questions, '1|yes|true|on', 'i')"
  />
  
  <!-- When set on, show feedback for answer options and entire questions
       in the output.  Default is "false" (suppress feedback).
    -->
  <xsl:param name="lc-show-feedback" as="xs:string" select="'false'"/>
  <xsl:variable name="lc:doShowFeedback" as="xs:boolean" 
    select="matches($lc-show-feedback, '1|yes|true|on', 'i')"
  />
  
  <!-- When set on, adds a class value to correct answer options to allow highlighting
       them using CSS. Default is "true"
    -->
  <xsl:param name="lc-style-correct-responses" as="xs:string" select="'true'"/>
  <xsl:variable name="lc:doStyleCorrectResponses" as="xs:boolean" 
    select="matches($lc-style-correct-responses, '1|yes|true|on', 'i')"
  />
  
  <!-- Default format string to use fordoShow generating question numbers. This
       value will be used by the xsl:number @format attribute.
    -->
  <xsl:param name="lc-question-number-format" as="xs:string" select="'1.'"/>

  <!-- Static prefix to put before question numbers. Default is "Q ". -->
  <xsl:param name="lc-question-number-prefix" as="xs:string" select="'Q '"/>

  <!-- Static suffix to put after question numbers. Default is " " (Single space). -->
  <xsl:param name="lc-question-number-suffix" as="xs:string" select="' '"/>
  
  <!-- Number format specification for answers options within an answer option group.
       
       Default is to number from A to D.
  -->
  <xsl:param name="lc-answer-option-number-format" as="xs:string" select="'A.'"/>
  
  <xsl:include href="plugin:org.dita.dita13base.html:xsl/dita13base2html.xsl"/>
  
  <!-- =====================
       True/False
       ===================== -->
  
  <xsl:template match="*[contains(@class, ' learning2-d/lcTrueFalse2 ')] |
                       *[contains(@class, ' learning-d/lcTrueFalse ')]">
    <xsl:call-template name="constructInteractionWithAnswerOptionGroup"/>    
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
  
  <xsl:template match="*[contains(@class, ' learning2-d/lcSingleSelect2 ')] |
                       *[contains(@class, ' learning-d/lcSingleSelect ')]">
    <xsl:call-template name="constructInteractionWithAnswerOptionGroup"/>    
  </xsl:template>
  
  <!-- =====================
       Answer Option Group
       ===================== -->
  
  <xsl:template match="*[contains(@class, ' learning2-d/lcAnswerOptionGroup2 ')] |
                       *[contains(@class, ' learning-d/lcAnswerOptionGroup ')]">
    <ol>
      <xsl:call-template name="lc-setClassAtt">
        <xsl:with-param name="baseClass" select="'lcAnswerOptionGroup'" as="xs:string*"/>
      </xsl:call-template>
      <xsl:apply-templates/>
    </ol>
  </xsl:template>

   
  <xsl:template match="*[contains(@class, ' learning2-d/lcAnswerOption2 ')] |
                       *[contains(@class, ' learning-d/lcAnswerOption ')]">
    <xsl:variable name="isCorrectAnswer" as="xs:boolean"
      select="boolean(./*[contains(@class, ' learning2-d/lcCorrectResponse2 ')] |
                       *[contains(@class, ' learning-d/lcCorrectResponse ')])"
    />
    <li>
      <xsl:call-template name="lc-setClassAtt">
        <xsl:with-param name="baseClass" 
          as="xs:string*"
          select="'lcAnswerOption', if ($isCorrectAnswer) then 'lc-correct-response' else ''" 
        />
      </xsl:call-template>
      <xsl:apply-templates select="." mode="lc-set-answer-option-label"/>
      <div class="lc-answer-option-content">
        <xsl:apply-templates/>
      </div>
    </li>
  </xsl:template>
  
  <xsl:template mode="lc-set-answer-option-label" 
    match="*[contains(@class, ' learning2-d/lcAnswerOption2 ')] |
           *[contains(@class, ' learning-d/lcAnswerOption ')]">
      <span class="lc-answer-option-label">
        <xsl:number count="*[contains(@class, ' learning2-d/lcAnswerOption2 ')] |
                           *[contains(@class, ' learning-d/lcAnswerOption ')]"
          format="{$lc-answer-option-number-format}"
          from="*[contains(@class, ' learning2-d/lcAnswerOptionGroup2 ')] |
                *[contains(@class, ' learning-d/lcAnswerOptionGroup ')]"
        /><xsl:text>&#xa0;</xsl:text>
      </span>
  </xsl:template>

  <!-- =====================
       Multiple Select
       ===================== -->
  
  <xsl:template match="*[contains(@class, ' learning2-d/lcMultipleSelect2 ')] | 
                       *[contains(@class, ' learning-d/lcMultipleSelect ')]">
    <xsl:call-template name="constructInteractionWithAnswerOptionGroup"/>    
  </xsl:template>

  <!-- =====================
       Sequencing
       ===================== -->

  <xsl:template match="*[contains(@class, ' learning2-d/lcSequencing2 ')] |
                       *[contains(@class, ' learning-d/lcSequencing ')]">
    <xsl:call-template name="constructInteractionWithAnswerOptionGroup"/>
  </xsl:template>
  
  <!-- =====================
       Matching
       ===================== -->
  <xsl:template match="*[contains(@class, ' learning2-d/lcMatching2 ')] |
                       *[contains(@class, ' learning-d/lcMatching ')]">
    <xsl:next-match/>
  </xsl:template>
  
  <!-- =====================
       Hotspot
       ===================== -->
  <xsl:template match="*[contains(@class, ' learning2-d/lcHotspot2 ')] |
                       *[contains(@class, ' learning-d/lcHotspot ')]">
    <xsl:next-match/>
  </xsl:template>
  
  <!-- =====================
       Open question
       ===================== -->
  <xsl:template match="*[contains(@class, ' learning2-d/lcOpenQuestion2 ')] |
                       *[contains(@class, ' learning-d/lcOpenQuestion ')]">
    <xsl:call-template name="constructInteractionWithAnswerOptionGroup"/>    
  </xsl:template>
  
  <!-- =====================
       Fallback handling
       ===================== -->
  <xsl:template match="*[contains(@class, ' learningInteractionBase2-d/lcInteractionBase2 ')] |
                       *[contains(@class, ' learningInteractionBase-d/lcInteractionBase ')]"
      priority="-0.5"
    >
    <!-- Fallback handling for interactions -->
    <div>
      <xsl:call-template name="commonattributes"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  <!-- ====================================================
       General interaction support templates and functions.
       ==================================================== -->
  
  <xsl:template name="constructInteractionWithAnswerOptionGroup">
    <xsl:param name="baseClass" as="xs:string*" select="lc:getBaseLcTypeForElement(.)"/>
    <div class="lc-interaction-wrapper">
      <xsl:apply-templates 
          select="*[contains(@class, ' learningInteractionBase2-d/lcInteractionLabel2 ')]"/>
      <p>
        <xsl:call-template name="commonattributes"/>
        <xsl:call-template name="lc-setClassAtt">
          <xsl:with-param name="baseClass" select="$baseClass" as="xs:string*"/>
        </xsl:call-template>
        <xsl:apply-templates 
          select="*[contains(@class, ' learningInteractionBase2-d/lcQuestionBase2 ')] |
                  *[contains(@class, ' learningInteractionBase-d/lcQuestionBase ')]"
        />
        <xsl:apply-templates 
          select="*[contains(@class, ' learning2-d/lcAnswerOptionGroup2 ')] |
                  *[contains(@class, ' learning-d/lcAnswerOptionGroup ')]"
        />
      </p>
    </div>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' learningInteractionBase2-d/lcInteractionLabel2 ')]">
    <p>
      <xsl:call-template name="commonattributes"/>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' learningInteractionBase2-d/lcQuestionBase2 ')] |
                       *[contains(@class, ' learningInteractionBase-d/lcQuestionBase ')]">
    <xsl:variable name="baseClass" as="xs:string"
      select="concat(lc:getBaseLcTypeForElement(..), 'Question')"
    />
    <div>
      <xsl:call-template name="lc-setClassAtt">
        <xsl:with-param name="baseClass" select="$baseClass" as="xs:string*"/>
      </xsl:call-template>
      <xsl:call-template name="lcGetQuestionNumber"/>
      <span class="lcQuestionText"><xsl:apply-templates/></span>
    </div>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' learning2-d/lcFeedback2 ')] |
                       *[contains(@class, ' learning-d/lcFeedback ')]">
    <xsl:message> + [DEBUG] lcFeedback: lc-show-feedback=<xsl:value-of select="$lc-show-feedback"/>"</xsl:message>
    <xsl:message> + [DEBUG] lcFeedback: lc:doShowFeedback=<xsl:value-of select="$lc:doShowFeedback"/>"</xsl:message>
    <xsl:if test="$lc:doShowFeedback">
      <div>
        <xsl:call-template name="lc-setClassAtt">
          <xsl:with-param name="baseClass" select="lc:getBaseLcTypeForElement(.)" as="xs:string*"/>
        </xsl:call-template>
        <xsl:apply-templates/>
      </div>
    </xsl:if>
  </xsl:template>
  
  <xsl:function name="lc:getBaseLcTypeForElement" as="xs:string">
    <xsl:param name="elem" as="element()"/>
    
    <!-- + topic/div learningInteractionBase2-d/lcInteractionBase2 learning2-d/lcMultipleSelect2  -->

    <xsl:variable name="lcType" as="xs:string"
      select="tokenize(tokenize($elem/@class, ' ')[4], '/')[2]"
    />
    <xsl:variable name="baseType" as="xs:string"
      select="if (contains($lcType, '2')) 
                 then substring-before($lcType, '2')
                 else $lcType"
    />
   <xsl:sequence select="$baseType"/>
  </xsl:function>
 
       
  <xsl:template name="lc-setClassAtt">
    <xsl:param name="baseClass" select="''" as="xs:string*"/>
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
    <xsl:message> + [DEBUG] lcGetQuestionNumber: $lc-number-questions=<xsl:value-of select="$lc-number-questions"/></xsl:message>
    <xsl:message> + [DEBUG] lcGetQuestionNumber: $lc:doNumberQuestions=<xsl:value-of select="$lc:doNumberQuestions"/></xsl:message>
    <xsl:message> + [DEBUG] lcGetQuestionNumber: not($lc:doNumberQuestions)=<xsl:value-of select="not($lc:doNumberQuestions)"/></xsl:message>
    <xsl:variable name="questionNumber" as="xs:string">
      <xsl:choose>
        <xsl:when test="not($lc:doNumberQuestions)">
          <xsl:sequence select="''"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:number 
            count="*[contains(@class, ' learningInteractionBase2-d/lcInteractionBase2 ')] |
                   *[contains(@class, ' learningInteractionBase-d/lcInteractionBase ')]"
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