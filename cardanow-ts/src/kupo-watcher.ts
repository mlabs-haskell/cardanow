import config from './config.js';

export default async () => {
  return fetch(`http://localhost:${config.kupoPort}/health`, { headers: {'Accept': 'application/json'} })
  .then((res) => res.json())
    .then((result) => {
      console.log(`Kupo response: ${JSON.stringify(result)}`)
      return result.most_recent_checkpoint != null && result.most_recent_checkpoint === result.most_recent_node_tip
    })
  .catch((e) => {
    console.error(e)
    return false
  })
}
