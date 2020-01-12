import React from 'react';
import { observer } from 'mobx-react';
import queryString from 'query-string';
import { History } from 'history';
import { makeStyles, fade } from '@material-ui/core/styles';
import ClearIcon from '@material-ui/icons/Clear';
import SearchIcon from '@material-ui/icons/Search';
import { IconButton } from '@material-ui/core';
import InputAdornment from '@material-ui/core/InputAdornment';
import InputBase from '@material-ui/core/InputBase';
import { CollectionStore } from '../stores/CollectionStore';

const useStyles = makeStyles(theme => ({
  search: {
    position: 'relative',
    borderRadius: theme.shape.borderRadius,
    backgroundColor: fade(theme.palette.common.white, 0.15),
    '&:hover': {
      backgroundColor: fade(theme.palette.common.white, 0.25),
    },
    marginLeft: 0,
    width: '100%',
    [theme.breakpoints.up('sm')]: {
      marginLeft: theme.spacing(1),
      width: 'auto',
    },
  },
  searchIcon: {
    width: theme.spacing(7),
    height: '100%',
    position: 'absolute',
    pointerEvents: 'none',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
  },
  inputRoot: {
    color: 'inherit',
  },
  inputInput: {
    padding: theme.spacing(1, 1, 1, 7),
    transition: theme.transitions.create('width'),
    width: '100%',
    [theme.breakpoints.up('sm')]: {
      width: 180,
      '&:focus': {
        width: 240,
      },
    },
  },
}))

interface SearchBarProps {
  store: CollectionStore
  history: History<any>
}

export const SearchBar: React.FC<SearchBarProps> = observer(({ store, history }) => {
  const classes = useStyles();

  const triggerSearch = (pattern: string) => {
    if (pattern.trim() === '') {
      store.searchKeywords(pattern);
      history.push('/')
    } else {
      const encoded: string = queryString.stringify({ "q": pattern });
      history.push(`/search/?${encoded}`)
    }
  }

  const handleClear = (event: React.MouseEvent<HTMLButtonElement>) =>
    triggerSearch('')

  const handleSearchChange = (event: React.ChangeEvent<HTMLInputElement>) =>
    triggerSearch(event.target.value)

  const handleSubmit = (event: React.KeyboardEvent<HTMLInputElement>) => {
    if (event.key === 'Enter') {
      triggerSearch(store.searchTerm)
    }
  }

  const clearIconAdornment: JSX.Element | null = store.searchTerm ?
    (<InputAdornment position="end">
      <IconButton onClick={handleClear}>
        <ClearIcon />
      </IconButton>
    </InputAdornment>) :
    null

  return (
    <div className={classes.search}>
      <div className={classes.searchIcon}>
        <SearchIcon />
      </div>
      <InputBase
        placeholder="Search…"
        classes={{
          root: classes.inputRoot,
          input: classes.inputInput,
        }}
        value={store.searchTerm}
        inputProps={{ 'aria-label': 'search' }}
        onChange={handleSearchChange}
        onKeyPress={handleSubmit}
        endAdornment={clearIconAdornment}
      />
    </div>
  )
})

export default SearchBar