#! /bin/bash
Encoding=UTF-8

echo '<window>
<text>
 <label>"Hello world"</label>   '$(: this can be used as a comment but actually these are arguments for the null command)'
</text>                         '$(: this is another comment)'
</window>' | gtkdialog -s
