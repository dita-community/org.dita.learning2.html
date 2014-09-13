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
          
        
        NOTE: variables named "lc:doXXX" are global booleans set from
              global parameters. Tunnel parameters named "lc:xxx" where
              "xxx" is the same as "XXX" from the "lc:doXXX" parameter, 
              allow overriding of the global default from calling templates.
              This lets you override the handling of any element that contains
              interactions in order to change details, such as showing
              feedback or only showing correct answers (e.g., generating
              an answer key from questions also shown as full questions
              in another context).
  
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
  
  <!-- Display only the feedback for a question, not the question (prompt)
       or any answer option content. This option lets you generate an
       answer key that has just answer option labels and feedback.
       
       Default is "no" (show other stuff in addition to feedback)
       
       If this is set to true, it implies lc-show-feedback.
    -->
  <xsl:param name="lc-show-only-feedback" as="xs:string" select="'no'"/>
  <xsl:variable name="lc:doShowOnlyFeedback" as="xs:boolean"
    select="matches($lc-show-only-feedback, '1|yes|true|on', 'i')"
  />

  <!-- When set on, show feedback for answer options and entire questions
       in the output.  Default is "false" (suppress feedback).
    -->
  <xsl:param name="lc-show-feedback" as="xs:string" select="'false'"/>
  <xsl:variable name="lc:doShowFeedback" as="xs:boolean" 
    select="matches($lc-show-feedback, '1|yes|true|on', 'i') or 
            $lc:doShowOnlyFeedback"
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
  
  <!-- Display only the question label and number (if numbered) and any 
       correct answers. Display of feedback is controlled through the
       separate lc-show-feedback parameter.
              
       Default is "no" (show whole question)
       
       NOTE: This option would only be used globally when producing
       a standalone answer-key publication. The corresponding 
       template-level parameter can be used from custom code
       to control this behavior dynamically within a single publication.
  -->
  <xsl:param name="lc-show-only-correct-answer" as="xs:string" select="'no'"/>
  <xsl:variable name="lc:doShowOnlyCorrectAnswer" as="xs:boolean"
    select="matches($lc-show-only-correct-answer, '1|yes|true|on', 'i')"
  />

  
  <xsl:variable name="baseBlockTypes" as="xs:string*"
     select="('dl',
              'fig',
              'image',
              'lines',
              'lq',
              'note',
              'object',
              'ol',
              'p',
              'pre',
              'simpletable',
              'sl',
              'table',
              'ul',
              'shortdesc')"
  />

  
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
    <xsl:param name="lc:showOnlyCorrectAnswer" as="xs:boolean" tunnel="yes"
      select="$lc:doShowOnlyCorrectAnswer"
    />
    
    <xsl:variable name="isCorrectAnswer" as="xs:boolean"
      select="boolean(./*[contains(@class, ' learning2-d/lcCorrectResponse2 ')] |
                       *[contains(@class, ' learning-d/lcCorrectResponse ')])"
    />
    <xsl:choose>
      <xsl:when test="($lc:showOnlyCorrectAnswer and not($isCorrectAnswer))">
        <!-- Do nothing: incorrect answers are suppressed -->
      </xsl:when>
      <xsl:when test="($lc:showOnlyCorrectAnswer and $isCorrectAnswer)">
        <!-- When we're only showing the correct answers, we have to generate
             the answer option label.
          -->
        <xsl:message> + [DEBUG] doShowOnlyCorrectAnswer=true, isCorrectAnswer.</xsl:message>
        <div>
          <xsl:call-template name="lc-setClassAtt">
            <xsl:with-param name="baseClass" 
              as="xs:string*"
              select="'lcAnswerOption', if ($isCorrectAnswer) then 'lc-correct-response' else ''" 
            />
          </xsl:call-template>
          <xsl:apply-templates select="." mode="lc-set-answer-option-label"/>
          <span class="lc-answer-option-content">
            <xsl:apply-templates select="if ($lc:doShowOnlyFeedback) 
              then (*[contains(@class, ' learning-d/lcFeedback ')] | 
                    *[contains(@class, ' learning2-d/lcFeedback2 ')])
              else node()"
            />
          </span>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <li>
          <xsl:call-template name="lc-setClassAtt">
            <xsl:with-param name="baseClass" 
              as="xs:string*"
              select="'lcAnswerOption', if ($isCorrectAnswer) then 'lc-correct-response' else ''" 
            />
          </xsl:call-template>
    <!--      <xsl:apply-templates select="." mode="lc-set-answer-option-label"/>-->
          <div class="lc-answer-option-content">
            <xsl:apply-templates/>
          </div>
        </li>
      </xsl:otherwise>
    </xsl:choose>
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
    <xsl:param name="lc:showOnlyCorrectAnswer" as="xs:boolean" tunnel="yes"
      select="$lc:doShowOnlyCorrectAnswer"
    />
    <xsl:variable name="interactionContents" as="node()*">
    </xsl:variable>
    <div class="lc-interaction-wrapper">
      <xsl:call-template name="commonattributes"/>
      <xsl:call-template name="lc-setClassAtt">
        <xsl:with-param name="baseClass" select="$baseClass" as="xs:string*"/>
      </xsl:call-template>
      <xsl:apply-templates 
          select="*[contains(@class, ' learningInteractionBase2-d/lcInteractionLabel2 ')]"/>
      <xsl:if test="not($lc:showOnlyCorrectAnswer)">
        <xsl:apply-templates 
          select="*[contains(@class, ' learningInteractionBase2-d/lcQuestionBase2 ')] |
                  *[contains(@class, ' learningInteractionBase-d/lcQuestionBase ')]"
        />
      </xsl:if>
      <xsl:apply-templates 
        select="*[contains(@class, ' learning2-d/lcAnswerOptionGroup2 ')] |
                *[contains(@class, ' learning-d/lcAnswerOptionGroup ')]"
      />
    </div>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' learningInteractionBase2-d/lcInteractionLabel2 ')]">
    <p>
      <xsl:call-template name="commonattributes"/>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' learningInteractionBase-d/lcQuestionBase ')]">
    <xsl:variable name="baseClass" as="xs:string"
      select="concat(lc:getBaseLcTypeForElement(..), 'Question')"
    />
    <!-- For learning1, lcQuestionBase specializes <p> --> 
    <p>
      <xsl:call-template name="lc-setClassAtt">
        <xsl:with-param name="baseClass" select="$baseClass" as="xs:string*"/>
      </xsl:call-template>
      <xsl:call-template name="lcGetQuestionNumber"/>
      <span class="lcQuestionText"><xsl:apply-templates/></span>
    </p>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' learningInteractionBase2-d/lcQuestionBase2 ')]">
    <xsl:variable name="baseClass" as="xs:string"
      select="concat(lc:getBaseLcTypeForElement(..), 'Question')"
    />
    <!-- For learning2, lcQuestionBase specializes <div> and may contain just text
         or block elements.
      -->
    <xsl:variable name="questionNumber" as="node()*">
      <xsl:call-template name="lcGetQuestionNumber"/>
    </xsl:variable>
    <xsl:variable name="textBeforeBlocks">
      <xsl:sequence select="(text() | *[not(lc:isBlock(.))])[not(preceding-sibling::*[lc:isBlock(.)])]"/>
    </xsl:variable>
    <xsl:variable name="hasTextBeforeBlocks" as="xs:boolean"
      select="normalize-space(string($textBeforeBlocks)) != ''"
    />
    <xsl:variable name="firstPara" as="node()*">
      <xsl:choose>
        <xsl:when test="not($hasTextBeforeBlocks) and lc:hasBlockChildren(.)">
          <!-- No text but there are blocks, so use the first one -->
          <xsl:apply-templates select="*[1]">
            <xsl:with-param name="questionNumber" select="$questionNumber" as="node()*"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <!-- There is text before the first block or there is only text, put it in a paragraph along
               with the question number.
            -->
          <p>
             <xsl:call-template name="commonattributes"/>
             <xsl:call-template name="setid"/>
            <xsl:sequence select="$questionNumber"/>
            <xsl:apply-templates select="$textBeforeBlocks"/>
          </p>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="remainingBlocks" as="node()*">
      <xsl:choose>
        <xsl:when test="$hasTextBeforeBlocks">
          <xsl:apply-templates select="node() except($textBeforeBlocks)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="*[position() > 1]"/>
        </xsl:otherwise>
      </xsl:choose>      
    </xsl:variable>
    <div>
      <xsl:call-template name="lc-setClassAtt">
        <xsl:with-param name="baseClass" select="'lc-question-wrapper'" as="xs:string*"/>
      </xsl:call-template>
      <xsl:sequence select="$firstPara"/>
      <xsl:sequence select="$remainingBlocks"/>
    </div>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' learningInteractionBase2-d/lcQuestionBase2 ')]/*[contains(@class, ' topic/p ')]">
    <xsl:param name="questionNumber" as="node()*"/>
    <!-- Outputs the question number if it's been specified. Used for the first paragraph within a question. -->
    <p>
      <xsl:call-template name="commonattributes"/>
      <xsl:call-template name="setid"/>
      <xsl:sequence select="$questionNumber"/>
      <xsl:apply-templates/>
    </p>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' learning-d/lcAnswerContent ')]">
    <span>
      <xsl:call-template name="lc-setClassAtt"/>
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' learning2-d/lcAnswerContent2 ')]">
    <span>
      <xsl:call-template name="lc-setClassAtt"/>
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' learning2-d/lcFeedback2 ')] |
                       *[contains(@class, ' learning-d/lcFeedback ')]">
    <xsl:param name="lc:showFeedback" as="xs:boolean" tunnel="yes"
      select="$lc:doShowFeedback"
    />
    
    <xsl:if test="$lc:showFeedback">
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
 
  <xsl:function name="lc:hasBlockChildren" as="xs:boolean">
    <xsl:param name="context" as="element()"/>
    <xsl:sequence select="boolean($context[
      *[contains(@class, ' topic/p ')] |
      *[contains(@class, ' topic/ol ')] |
      *[contains(@class, ' topic/ul ')] |
      *[contains(@class, ' topic/sl ')] |
      *[contains(@class, ' topic/example ')] |
      *[contains(@class, ' topic/fig ')] |
      *[contains(@class, ' topic/figgroup ')] |
      *[contains(@class, ' topic/lines ')] |
      *[contains(@class, ' topic/note ')] |
      *[contains(@class, ' topic/pre ')] |
      *[contains(@class, ' topic/simpletable ')] |
      *[contains(@class, ' topic/table')]
      ])"/>
  </xsl:function>
  
  <xsl:function name="lc:isBlock" as="xs:boolean">
    <xsl:param name="context" as="element()"/>
    <xsl:variable name="result" as="xs:boolean">
      <xsl:choose>
          <xsl:when test="contains($context/@class, ' topic/')">
            <xsl:variable name="baseType"
              select="substring-after(tokenize($context/@class, ' ')[2], '/')"
            />
            <xsl:sequence select="$baseType = $baseBlockTypes"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="false()"/>
          </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>  
    <xsl:sequence select="$result"/>
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