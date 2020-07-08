<?php
$conn = new mysqli("127.0.0.1", "moral", "j|n321", "adam");
$subject=$_POST['subject'];
$iri_1 = $_POST['iri_1'];
$iri_2 = $_POST['iri_2'];
$iri_3 = $_POST['iri_3'];
$iri_4 = $_POST['iri_4'];
$iri_5 = $_POST['iri_5'];
$iri_6 = $_POST['iri_6'];
$iri_7 = $_POST['iri_7'];
$iri_8 = $_POST['iri_8'];
$iri_9 = $_POST['iri_9'];
$iri_10 = $_POST['iri_10'];
$iri_11 = $_POST['iri_11'];
$iri_12 = $_POST['iri_12'];
$iri_13 = $_POST['iri_13'];
$iri_14 = $_POST['iri_14'];
$iri_15 = $_POST['iri_15'];
$iri_16 = $_POST['iri_16'];
$iri_17 = $_POST['iri_17'];
$iri_18 = $_POST['iri_18'];
$iri_19 = $_POST['iri_19'];
$iri_20 = $_POST['iri_20'];
$iri_21 = $_POST['iri_21'];
$iri_22 = $_POST['iri_22'];
$iri_23 = $_POST['iri_23'];
$iri_24 = $_POST['iri_24'];
$iri_25 = $_POST['iri_25'];
$iri_26 = $_POST['iri_26'];
$iri_27 = $_POST['iri_27'];
$iri_28 = $_POST['iri_28'];

$sql="INSERT INTO `osborn_social_mf_iri` (`subject`, 
`iri_1`,`iri_2`,`iri_3`,`iri_4`,`iri_5`,`iri_6`,`iri_7`,`iri_8`, `iri_8`, `iri_9`, `iri_10`, 
`iri_11`, `iri_12`, `iri_13`, `iri_14`,`iri_15`,`iri_16`,`iri_17`,`iri_18`,`iri_19`,`iri_20`,
`iri_21`,`iri_22`,`iri_23`,`iri_24`,`iri_25`,`iri_26`,`iri_27`,`iri_28`,)  VALUES ('$study_id',
'$iri_1','$iri_2','$iri_3','$iri_4','$iri_5','$iri_6','$iri_7','$iri_8','$iri_9','$iri_10',
'$iri_11','$iri_12','$iri_13','$iri_14','$iri_15','$iri_16','$iri_17','$iri_18','$iri_19','$iri_20',
'$iri_21','$iri_22','$iri_23','$iri_24','$iri_25','$iri_26','$iri_27','$iri_28')";
if ($conn->query($sql) === TRUE) {
   echo 'progress saved';
}
else 
{
    echo 'error saving progres';
}
?>