import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'

class SearchWithReact extends React.Component<any, any>{
    componentDidMount() {
        fetch('info')
            .then(response => response.json())
            .then(data => console.log(data));
    }
}

document.addEventListener('DOMContentLoaded', () => {
    ReactDOM.render(
        <SearchWithReact />,
        document.body.appendChild(document.createElement('div')),
    )
})

