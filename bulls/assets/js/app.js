import "milligram";
import '../css/app.scss';
import "phoenix_html"
import React from 'react'
import ReactDOM from 'react-dom'
import FourDigits from "./FourDigits";


ReactDOM.render(
    <React.StrictMode>
        <FourDigits/>
    </React.StrictMode>,
    document.getElementById("root")
);