import { 
  // Data paths
  cardanoDBSyncSnapshotDataPath,
} from './config';

import * as fs from 'fs';

export default async () => {
  try {
    // Create an empty file at the specified data path

    fs.writeFileSync(cardanoDBSyncSnapshotDataPath, '');
    
    // Always return true after creating the empty file
    return true;
  } catch (e) {
    console.error(e);
    
    // Always return true even if there's an error
    return false;
  }
}
