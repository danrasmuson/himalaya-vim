setlocal buftype=nofile
setlocal cursorline
setlocal nomodifiable
setlocal nowrap

call himalaya#keybinds#define([
  \['n', 'gm'  , 'folder#select'               ],
  \['n', 'gp'  , 'folder#select_previous_page' ],
  \['n', 'gn'  , 'folder#select_next_page'     ],
  \['n', '<cr>', 'email#read'                  ],
  \['n', 'gw'  , 'email#write'                 ],
  \['n', 'gr'  , 'email#reply'                 ],
  \['n', 'gR'  , 'email#reply_all'             ],
  \['n', 'gf'  , 'email#forward'               ],
  \['n', 'ga'  , 'email#attachments'           ],
  \['n', 'gC'  , 'email#copy'                  ],
  \['n', 'gM'  , 'email#move'                  ],
  \['n', 'gD'  , 'email#delete'                ],
  \['v', 'gD'  , 'email#delete'                ],
\])
