% Maintainer: Gaurav Raj (@thehackersbrain) <me@thehackersbrain.xyz>
% Author: José Areia <jose.apareia@gmail.com>

%%% Class Information %%%
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{main}[2025/08/23 Gaurav Raj - Thesis Template]

\RequirePackage{expl3} % Required for writing LaTeX3 code in this class.

%%% Handle Class Options %%%
\ExplSyntaxOn


\cs_new:Npn \check_color:n #1 {
  \tl_set:Nn \l_tmpa_tl { #1 }
  \color_set:nn { \l_tmpa_tl } { #1 }
}

\keys_define:nn { main } {
    docstage .choices:nn =
        { working, final } 
        { \tl_gset:Nn \g_main_docstage_tl { #1 } },
    docstage / unknown .code:n = 
        { \ClassWarningNoLine{main}{Specified~'docstage'~not~available.~Defaulting~to~'working'} },
    docstage .default:n = { working },
    docstage .initial:n = { working },

    media .choices:nn = 
        { paper, screen } 
        { \tl_gset:Nn \g_main_media_tl { #1 } },
    media / unknown .code:n = 
        { \ClassWarningNoLine{main}{Specified~'media'~not~available.~Defaulting~to~'paper'} },
    media .default:n = { paper },
    media .initial:n = { paper },

    linkcolor .code:n = {
        \tl_gset:Nn \g_main_linkcolor_tl { #1 }
        \check_color:n { #1 }
        \tl_if_eq:NNTF \l_tmpa_tl \q_no_value {
            \tl_gset:Nn \g_main_linkcolor_tl { black }
            \ClassWarningNoLine{main}{Specified~'linkcolor'~not~available.~Defaulting~to~'black'}
        }
    },
    linkcolor .default:n = { black },
    linkcolor .initial:n = { black },

    doctype .choices:nn = 
        { thesis, report } 
        { \tl_gset:Nn \g_main_doctype_tl { #1 } },
    doctype / unknown .code:n = 
        { \ClassWarningNoLine{main}{Specified~'doctype'~not~available.~Defaulting~to~'thesis'} },
    doctype .default:n = { thesis },
    doctype .initial:n = { thesis },

    unknown .code:n =
        { \ClassWarningNoLine{main}{An~unknown~option~was~ignored.~Please~check~the~documentation~to~see~the~available~options} }
}

\newcommand{\DocStageOption}{\g_main_docstage_tl}
\newcommand{\MediaOption}{\g_main_media_tl}
\newcommand{\ColorOption}{\g_main_linkcolor_tl}
\newcommand{\DocTypeOption}{\g_main_doctype_tl}

\ProcessKeyOptions[main]
\ExplSyntaxOff

%%% Load Master Class %%%
\LoadClass[a4paper,12pt,twoside]{report}

%%% Required Packages %%%
\RequirePackage[english]{babel}
\RequirePackage{ifthen} % Provides conditional statements.
\RequirePackage{etoolbox} % Advanced programming tools for LaTeX.
\RequirePackage{graphicx} % For including and manipulating images.
\RequirePackage{subcaption} % Subfigures and side-by-side captions.
\RequirePackage{tabularx} % Flexible-width tables.
\RequirePackage{xltabular} % Same as tabularx but to be used in long tables.
\RequirePackage{booktabs} % Professional table styling.
\RequirePackage{multirow} % Support for multirow cells in tables.
\RequirePackage{longtable} % Tables spanning multiple pages.
\RequirePackage{caption} % Customisation of captions.
\RequirePackage{enumitem} % Customisation of lists.
\RequirePackage{amsmath} % Advanced mathematical expressions.
\RequirePackage{amssymb} % Extended mathematical symbols.
\RequirePackage{amsthm} % Support for theorems.
\RequirePackage[dvipsnames]{xcolor} % Extended color support.
\RequirePackage{tcolorbox} % Creating colored and highlighted boxes.
\RequirePackage{varwidth} % Allows variable-width boxes.
\RequirePackage{titlesec} % Customisation of section and chapter titles.
\RequirePackage{titling} % Control over title and titlepage formatting.
\RequirePackage[toc,page]{appendix} % Formatting for appendices.
\RequirePackage[bookmarks,pdfusetitle]{hyperref} % Hyperlinks and PDF metadata.
\RequirePackage[symbols,acronym]{glossaries} % Create glossaries and acronyms.
\RequirePackage[calc,datesep={/}]{datetime2} % Enhanced date and time formatting.
\RequirePackage{xparse} % Advanced argument parsing for custom macros.
\RequirePackage{typearea} % Page layout adjustments (KOMA-Script).
\RequirePackage{eso-pic} % Adding elements to the page background.
\RequirePackage{setspace} % Adjust line spacing.
\RequirePackage[newfloat]{minted} % Syntax highlighting for code.
\RequirePackage{silence} % Suppress specific package warnings.
\RequirePackage{fontawesome5} % Font awesome icons.
\RequirePackage{calc} % Infix notation arithmetic.
\RequirePackage{soul} % A better underline.
\RequirePackage{mfirstuc} % Capitalise words in a sentence.
\RequirePackage{tikz} % Create high-quality graphics programmatically.
\RequirePackage{psvectorian} % To include in-text ornamatentions. 
\RequirePackage{blindtext} % Generate placeholder text.
\RequirePackage{pgfplots} % for generating graphs and plots.
\usepackage{siunitx} % Better SI unit mapping in graphs/formulas.
\usepackage[version=4]{mhchem}

\tcbuselibrary{most} % Load most libraries from the tcolorbox package.
\WarningsOff[blindtext] % Suppress warnings from the blindtext package.
\usetikzlibrary{quotes,angles}
\pgfplotsset{compat=1.8}
\newtheorem{theorem}{Theorem}

%%% Import Configurations - Maintain the Specified Order! %%%
\usepackage{Configurations/00-Fonts}
\usepackage{Configurations/01-Colors}
\usepackage{Configurations/02-Margins}
\usepackage{Configurations/03-References}
\usepackage{Configurations/04-Headers}
\usepackage{Configurations/05-Contents}
\usepackage{Configurations/06-Glossary}
\usepackage{Configurations/07-Chapters}
\usepackage{Configurations/08-Tables}
\usepackage{Configurations/09-Code}
\usepackage{Configurations/10-Macros}
\usepackage{Configurations/11-Metadata}
