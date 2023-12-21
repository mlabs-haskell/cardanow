export default async () => {
  return fetch("http://localhost:1442/health", { headers: {'Accept': 'application/json'} })
  .then((res) => res.json())
  .then((result) => {
    if (result.most_recent_checkpoint === result.most_recent_node_tip) {
      return true
    } else {
      return false
    }
  })
  .catch((e) => {
    console.error(e)
    return false
  })
}
