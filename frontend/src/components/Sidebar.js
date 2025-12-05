import React from "react";
import { Link } from "react-router-dom";
import "../styles/sidebar.css";

const Sidebar = () => {
  return (
    <div className="sidebar">
      <h3 className="logo">University DB</h3>
      <ul>
        <li><Link to="/students">Students</Link></li>
        <li><Link to="/professors">Professors</Link></li>
        <li><Link to="/courses">Courses</Link></li>
        <li><Link to="/degrees">Degrees</Link></li>
        <li><Link to="/departments">Departments</Link></li>
      </ul>
    </div>
  );
};

export default Sidebar;
