let sharedData = {};

export function setSharedData(data) {
  sharedData = data;
}

export function getSharedData() {
  return sharedData;
}