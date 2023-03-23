import { ref, computed } from 'vue'
import { defineStore } from 'pinia'

export interface FilterDimension {
  key: string,
  value: string
}

export interface Content {
  id: string,
  title: string,
  description: string,
  image: string,
  filterDimensions: Array<FilterDimension>
}

export interface Filter {
  key: string,
  value: string,
  label: string,
  color: string,
  checked: boolean
}

export interface FilterGroup {
  key: string,
  label: string
}

export const useContentStore = defineStore('content', () => {
  const content = ref([] as Array<Content>)
  const filters = ref([] as Array<Filter>)
  const filterGroups = ref([] as Array<FilterGroup>)

  // Computed dictionary of filters by key
  const filtersByKeyValue = computed(() => {
    var dict = {}
    filters.value.forEach(function (filter) {
      dict[`${filter.key}:${filter.value}`] = filter;
    })
    return dict;
  })

  // Computed dictionary of filter groups by key
  const filterGroupsByKey = computed(() => {
    var dict = {}
    filterGroups.value.forEach(function (filterGroup) {
      dict[filterGroup.key] = filterGroup;
    })
    return dict;
  })

  // A computed list of filters organized by filter group, used for rendering the
  // sidebar filter component
  const filterList = computed(() => {
    return filterGroups.value.map((group) => {
      return {
        key: group.key,
        label: group.label,
        filters: filters.value.filter(thisFilter => thisFilter.key === group.key)
      }
    })
  })

  // A computed list of just the checked filters. Used to accelerate other computations.
  const checkedFilters = computed(() => {
    return filters.value.filter(thisFilter => thisFilter.checked === true)
  })

  // A list of the required categories that have checked filters.
  // Users can multiselect within a single category. A piece of content
  // has to match at least one of the checked filters inside of that
  // category.
  const filterCategories = computed(() => {
    var categories = new Set();
    for (const checkedFilter of checkedFilters.value) {
      categories.add(checkedFilter.key)
    }
    return [...categories];
  })

  // A computed list of the available content filtered according to
  // the checked filters.
  const filteredContent = computed(() => {
    // Fast path: if no filters are applied, then return all content.
    if (checkedFilters.value.length == 0) {
      return content.value;
    }

    // If filters are applied then find at least one match in each category
    return content.value.filter(function (thisContent) {
      for (const requiredCategory of filterCategories.value) {
        let matchedCategory = false;
        for (const dimension of thisContent.filterDimensions) {
          if ((dimension.key == requiredCategory)) {
            for (const checkedFilter of checkedFilters.value) {
              if (checkedFilter.value === dimension.value) {
                matchedCategory = true;
                break;
              }
            }
          }
        }

        if (!matchedCategory) {
          return false;
        }
      }

      return true;
    });
  })

  // A computed list of the filtered content with the human readable labels applied to it.
  const labelledFilteredContent = computed(() => {
    // Apply labels to all the content based on it's dimensions
    return filteredContent.value.map((contentPiece) => {
      return {
        ...contentPiece,
        tags: contentPiece.filterDimensions.map(function (dimension) {
          return filters.value.find(function (filter) {
            return (filter.key == dimension.key) && (filter.value == dimension.value);
          })
        })
      }
    });
  })

  // Action which resets all checked filters, causing all other
  // computed properties to be recalculated.
  function resetAllFilters() {
    for (const filter of filters.value) {
      filter.checked = false;
    }
  }

  // Expose all stored values and computed values to
  // consumers of the store.
  return {
    content,
    filteredContent,
    filters,
    filterGroups,
    filterList,
    labelledFilteredContent,
    resetAllFilters,
    filtersByKeyValue,
    filterGroupsByKey
  }
});