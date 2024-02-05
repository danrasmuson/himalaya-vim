setlocal buftype=nofile
setlocal cursorline
setlocal nomodifiable
setlocal nowrap

call himalaya#keybinds#define([
  \['n', 'gm'  , 'folder#select'                ],
  \['n', 'gp'  , 'folder#select_previous_page'  ],
  \['n', 'gn'  , 'folder#select_next_page'      ],
  \['n', '<cr>', 'email#read'                   ],
  \['n', 'gw'  , 'email#write'                  ],
  \['n', 'gr'  , 'email#reply'                  ],
  \['n', 'gR'  , 'email#reply_all'              ],
  \['n', 'gf'  , 'email#forward'                ],
  \['n', 'ga'  , 'email#download_attachments'   ],
  \['n', 'gC'  , 'email#select_folder_then_copy'],
  \['n', 'gM'  , 'email#select_folder_then_move'],
  \['n', 'e'  , 'email#move_to_all_mail'],
  \['n', 'gD'  , 'email#delete'                 ],
  \['v', 'gD'  , 'email#delete'                 ],
\])
