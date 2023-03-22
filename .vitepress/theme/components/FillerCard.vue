<template>
  <div class="content-card">
  </div>
</template>

<style scoped>
.content-card {
  flex: 0 1 calc(25% - .5em);
}

@media screen and (max-width: 1600px) {
  .content-card {
    flex: 0 1 calc(25% - .5em);
  }
}

@media screen and (max-width: 1400px) {
  .content-card {
    flex: 0 1 calc(33% - .5em);
  }
}

@media screen and (max-width: 1200px) {
  .content-card {
    flex: 0 1 calc(50% - .5em);
  }
}

@media screen and (max-width: 1000px) {
  .content-card {
    flex: 0 1 calc(100% - .5em);
  }
}
</style>