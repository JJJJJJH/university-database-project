import React, { useState } from "react";
import { Table, Form, Button } from "react-bootstrap";

const Departments = () => {
  const [departments, setDepartments] = useState([]);
  const [form, setForm] = useState({
    dept_id: "",
    dept_name: "",
    location: "",
  });

  const [editingId, setEditingId] = useState(null);

  // Handle form change
  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  // Insert or update
  const handleSubmit = (e) => {
    e.preventDefault();

    if (editingId === null) {
      const newDept = {
        id: Date.now(),
        ...form,
      };
      setDepartments([...departments, newDept]);
    } else {
      const updatedList = departments.map((d) =>
        d.id === editingId ? { ...d, ...form } : d
      );
      setDepartments(updatedList);
      setEditingId(null);
    }

    setForm({ dept_id: "", dept_name: "", location: "" });
  };

  // Edit department
  const handleEdit = (dept) => {
    setForm({
      dept_id: dept.dept_id,
      dept_name: dept.dept_name,
      location: dept.location,
    });
    setEditingId(dept.id);
  };

  // Delete department
  const handleDelete = (id) => {
    setDepartments(departments.filter((d) => d.id !== id));
  };

  return (
    <div>
      <h3>Departments Module</h3>

      {/* FORM */}
      <Form onSubmit={handleSubmit} className="mb-4">
        <Form.Group className="mb-2">
          <Form.Label>Department ID</Form.Label>
          <Form.Control
            name="dept_id"
            value={form.dept_id}
            onChange={handleChange}
            required
          />
        </Form.Group>

        <Form.Group className="mb-2">
          <Form.Label>Department Name</Form.Label>
          <Form.Control
            name="dept_name"
            value={form.dept_name}
            onChange={handleChange}
            required
          />
        </Form.Group>

        <Form.Group className="mb-2">
          <Form.Label>Location</Form.Label>
          <Form.Control
            name="location"
            value={form.location}
            onChange={handleChange}
            required
          />
        </Form.Group>

        <Button type="submit" variant={editingId ? "warning" : "primary"}>
          {editingId ? "Update Department" : "Add Department"}
        </Button>
      </Form>

      {/* TABLE */}
      <Table striped bordered hover>
        <thead>
          <tr>
            <th>Department ID</th>
            <th>Name</th>
            <th>Location</th>
            <th>Actions</th>
          </tr>
        </thead>

        <tbody>
          {departments.length === 0 ? (
            <tr>
              <td colSpan="4" className="text-center">
                No departments added yet.
              </td>
            </tr>
          ) : (
            departments.map((d) => (
              <tr key={d.id}>
                <td>{d.dept_id}</td>
                <td>{d.dept_name}</td>
                <td>{d.location}</td>
                <td>
                  <Button
                    variant="info"
                    size="sm"
                    className="me-2"
                    onClick={() => handleEdit(d)}
                  >
                    Edit
                  </Button>

                  <Button
                    variant="danger"
                    size="sm"
                    onClick={() => handleDelete(d.id)}
                  >
                    Delete
                  </Button>
                </td>
              </tr>
            ))
          )}
        </tbody>
      </Table>
    </div>
  );
};

export default Departments;
