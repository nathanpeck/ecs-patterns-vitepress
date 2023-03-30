<template>
  <div class="filler-card">
  </div>
</template>

<style>
.filler-card {
  flex: 0 1 calc(25% - .5em);
}

@media screen and (max-width: 1600px) {
  .filler-card {
    flex: 0 1 calc(25% - .5em);
  }
}

@media screen and (max-width: 1400px) {
  .filler-card {
    flex: 0 1 calc(33% - .5em);
  }
}

@media screen and (max-width: 1200px) {
  .filler-card {
    flex: 0 1 calc(50% - .5em);
  }
}

@media screen and (max-width: 1000px) {
  .filler-card {
    flex: 0 1 calc(100% - .5em);
  }
}
</style>