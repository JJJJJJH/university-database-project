import { BrowserRouter as Router, Routes, Route, Link } from "react-router-dom";
import Professors from "./pages/Professors";
import Students from "./pages/Students";
import Courses from "./pages/Courses";
import Degrees from "./pages/Degrees";
import Departments from "./pages/Departments";
import "bootstrap/dist/css/bootstrap.min.css";

function App() {
  return (
    <Router>
      <div className="container mt-4">
        <h2 className="text-center mb-4">University Database System</h2>

        {/* Navigation */}
        <nav className="mb-4">
          <ul className="nav nav-tabs">
            <li className="nav-item">
              <Link className="nav-link" to="/professors">Professors</Link>
            </li>
            <li className="nav-item">
              <Link className="nav-link" to="/students">Students</Link>
            </li>
            <li className="nav-item">
              <Link className="nav-link" to="/courses">Courses</Link>
            </li>
            <li className="nav-item">
              <Link className="nav-link" to="/degrees">Degrees</Link>
            </li>
            <li className="nav-item">
              <Link className="nav-link" to="/departments">Departments</Link>
            </li>
          </ul>
        </nav>

        {/* Routing */}
        <Routes>
          <Route path="/professors" element={<Professors />} />
          <Route path="/students" element={<Students />} />
          <Route path="/courses" element={<Courses />} />
          <Route path="/degrees" element={<Degrees />} />
          <Route path="/departments" element={<Departments />} />
          
          {/* Default */}
          <Route path="/" element={<h3>Welcome! Select a module above.</h3>} />
        </Routes>
      </div>
    </Router>
  );
}

export default App;
