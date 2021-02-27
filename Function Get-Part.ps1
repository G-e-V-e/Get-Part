<#
.Synopsis
	Splits a String into parts and joins them back together from From part to To part using a Delimiter.
.Description
	Returns the requested part of a string based on its splitted parts and joined using a delimiter string.
	1. Split String in an array using regular expression Split (or Delimiter if Split is omitted).
	2. Remove empty parts if switch NotEmpty is true.
	3. Parts are joined using Delimiter from From to To.
.Parameter String
    The string to be handled. Pipelined input strings are accepted.
.Parameter From (alias F, Begin, B)
    The index of the first part to be returned. 
	If the first character of From is a digit, From must be convertible to an integer forward index relative to the first part (with index 0).
	Any other first character of From must be followed by an expression convertible to an integer backward index relative to the last part (with index Count-1).
	So '2' refers to the third part, 'h1' refers to the before last part. Default is '0' (the first part).
.Parameter To (alias T, End, E)
    The index of the last part to be returned. 
	If the first character of To is a digit, To must be convertible to an integer forward index, relative to the first part (with index 0).
	Any other first character of To must be followed by an expression convertible to an integer backward index, relative to the last part (with index Count-1).
	So 'x0 refers to the index of the last part, '1' is the index of the second part. Default is the last part.
.Parameter Split
    The regular expression string acting for splitting the string in parts. Default is the Delimiter value. 
	Regular expression escape character must be inserted manually as required.
.Parameter Delimiter (alias D)
    The string acting as delimiter for joining the string from the parts. Default is a single space character. 
	When used as Split string, regular expression escape character are inserted by this script.
.Parameter NotEmpty (alias N)
    Switch indicating empty parts will be dropped.
.Example
	AD object magic:
	Get-Part 'ou=Child,ou=Parent1,ou=Parent2,dc=Domain' -From 1 -Delimiter ','						==>	'ou=Parent1,ou=Parent2,dc=Domain'
	Get-Part 'ou=Child,ou=Parent1,ou=Parent2,dc=Domain' -d ',' -split 'ou=|dc=|,' -NotEmpty			==> 'Child,Parent1,Parent2,Domain'
	Get-Part 'ou=Child,ou=Parent1,ou=Parent2,dc=Domain' -T '000.' -D ','							==>	'ou=Child'
	Get-Part 'ou=Child,ou=Parent1,ou=Parent2,dc=Domain' -Begin 1 -End 1 -Split '[,=]'				==>	'Child'
.Example
	FullName magic:
	'C:\Folder1\Folder2\Folder3\Folder4\Folder5\File.ext' | Get-Part -t 0 -d '\'					==> 'C:'
	'C:\Folder1\Folder2\Folder3\Folder4\Folder5\File.ext' | Get-Part -f 1 -t ?1 -d '\'				==> 'Folder1\Folder2\Folder3\Folder4\Folder5'
	'C:\Folder1\Folder2\Folder3\Folder4\Folder5\File.ext' | Get-Part -f h1 -t h1 -d '\'				==> 'Folder5'
	'C:\Folder1\Folder2\Folder3\Folder4\Folder5\File.ext' | Get-Part -f /1 -d '\'					==> 'File.ext'
	'C:\Folder1\Folder2\Folder3\Folder4\Folder5\File.ext' | Get-Part -f -0 -d '.'					==> 'ext'
	Item $ExistingFilePath | Part -f 'X0' -t '@ -000.' -d '\'										==> 'FileName.ext'
.Example
	Reverse a string:
	Part '1<=>2<=>3<=>4<=>5' -0 0 '<=>'																==>	'5<=>4<=>3<=>2<=>1'
.Example
	Clean up the mess:
	'This    is ,,,, a string' | Part -split '[ ,]' -NotEmpty										==>	'This is a string'
.Inputs
	Multiple System.String arguments. Both unnamed and named ('String','FullName','Name') pipe input is supported.
.Outputs
	System.String
.Notes
	Author:	geve.one2one@gmail.com  
#>
Function Get-Part
{
[CmdletBinding()]
param	(
		[Alias('Name')][Parameter(Position=0,Mandatory,ValueFromPipeLine,ValueFromPipelineByPropertyName)][string]$String,
		[Alias('B','Begin','F')][Parameter(Position=1)][String]$From='0',
		[Alias('E','End','T')][Parameter(Position=2)][String]$To='-0',
		[Alias('D')][Parameter(Position=3)][string]$Delimiter=' ',
		[Parameter(Position=4)][string]$Split,
		[Alias('N')][switch]$NotEmpty
		)
if		($Split)			{[array]$part = $String -split $Split}			else	{[array]$part = $String -split [Regex]::Escape($Delimiter)}
if		($NotEmpty)			{$part = $part.Where({$_ -ne ''})}
if		($From.substring(0,1)	-match '[0-9]')		{[int]$From	= $From}	else	{[int]$From	= $Part.Count - [int]$From.substring(1) - 1}
if		($To.substring(0,1)		-match '[0-9]')		{[int]$To	= $To}		else	{[int]$To	= $Part.Count - [int]$To.substring(1) - 1}
$Part[$From..$To] -join $Delimiter
}
