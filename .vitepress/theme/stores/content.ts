import { ref, computed } from 'vue'
import { defineStore } from 'pinia'
import { useLocalStorage, usePreferredDark } from '@vueuse/core'

export interface FilterDimension {
  key: string,
  value: string
}

export interface Content {
  id: string,
  title: string,
  description: string,
  image: string,
  filterDimensions: Array<FilterDimension>,
  authors: Array<string>,
  date: Date
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

enum LinkType {
  website = 'website',
  github = 'github',
  twitter = 'twitter'
}

export interface Link {
  type: LinkType,
  uri: string
}

export interface Author {
  id: string,
  name: string,
  title: string,
  image: string,
  links: Array<Link>
}

export const useContentStore = defineStore('content', () => {
  const content = ref([] as Array<Content>)
  const filters = ref([] as Array<Filter>)
  const filterGroups = ref([] as Array<FilterGroup>)
  const authors = ref([] as Array<Author>)
  const darkMode = ref(false)

  // Set the initial dark mode value. This
  // will be reconfigured in browser side code.
  // This is client side code that only works in the browser
  let preferredDefault;

  const isDarkPreferred = usePreferredDark();

  if (isDarkPreferred.value) {
    preferredDefault = 'dark'
  } else {
    preferredDefault = 'light'
  }

  const themeSetting = useLocalStorage('theme', preferredDefault)

  // The following computed properties are automatically reactive,
  // meaning that the code within the `computed` function runs
  // automatically whenever the referenced base variables from above
  // change values. This allows us to regenerate computed properties
  // automatically whenever an action is taken like enabling a filter

  // Computed dictionary of team members by id
  const authorsById = computed(() => {
    var dict = {}
    authors.value.forEach(function (teamMember) {
      dict[teamMember.id] = teamMember;
    })
    return dict;
  });

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

  // A computed list of the content which has had human readable labels
  // attached to the content. This grabs the human readable name for
  // the tags attached to a post, and the human readable author name instead
  // of the author id.
  const labelledContent = computed(() => {
    // Apply labels to all the content based on it's dimensions
    return content.value.map((contentPiece) => {
      if (!contentPiece.filterDimensions) {
        contentPiece.filterDimensions = [];
      }

      if (!contentPiece.authors) {
        contentPiece.authors = [];
      }

      return {
        ...contentPiece,
        tags: contentPiece.filterDimensions.map(function (dimension) {
          return filtersByKeyValue.value[`${dimension.key}:${dimension.value}`]
        }),
        authorDetails: contentPiece.authors.map(function (authorId) {
          return authorsById.value[authorId]
        })
      }
    });
  })

  // A computed list of the available content filtered according to
  // the checked filters.
  const labelledFilteredContent = computed(() => {
    // Fast path: if no filters are applied, then return all content.
    if (checkedFilters.value.length == 0) {
      return labelledContent.value;
    }

    // If filters are applied then find at least one match from each category
    return labelledContent.value.filter(function (thisContent) {
      for (const requiredCategory of filterCategories.value) {
        let matchedCategory = false;
        for (const dimension of thisContent.filterDimensions) {
          if ((dimension.key == requiredCategory)) {
            if (!filtersByKeyValue.value[`${dimension.key}:${dimension.value}`]) {
              console.error(`Failed to find filter ${dimension.key}:${dimension.value}`);
            }

            if (filtersByKeyValue.value[`${dimension.key}:${dimension.value}`].checked) {
              matchedCategory = true;
              break;
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

  // A computed dictionary of content pieces per author
  const labelledContentByAuthor = computed(() => {
    const dict = {}

    // Prepopulate an empty array for each team member
    for (const author of authors.value) {
      dict[author.id] = [];
    }

    // Put each piece of content into the list of each author
    for (const thisContent of labelledContent.value) {
      for (const thisAuthor of thisContent.authors) {
        dict[thisAuthor].push(thisContent);
      }
    }

    return dict;
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
    filters,
    filterGroups,
    filterList,
    labelledFilteredContent,
    resetAllFilters,
    filtersByKeyValue,
    filterGroupsByKey,
    authors,
    authorsById,
    labelledContentByAuthor,

    // For global usage by components that want to mutate
    // or implement dark mode
    themeSetting
  }
});