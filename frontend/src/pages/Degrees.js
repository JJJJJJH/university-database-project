import React, { useState } from "react";
import { Table, Form, Button } from "react-bootstrap";

const Degrees = () => {
  const [degrees, setDegrees] = useState([]);
  const [form, setForm] = useState({
    degree_id: "",
    degree_name: "",
    duration: "",
  });

  const [editingId, setEditingId] = useState(null);

  // Handle input change
  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  // Insert or update
  const handleSubmit = (e) => {
    e.preventDefault();

    if (editingId === null) {
      const newDegree = {
        id: Date.now(),
        ...form,
      };
      setDegrees([...degrees, newDegree]);
    } else {
      const updatedList = degrees.map((d) =>
        d.id === editingId ? { ...d, ...form } : d
      );
      setDegrees(updatedList);
      setEditingId(null);
    }

    setForm({ degree_id: "", degree_name: "", duration: "" });
  };

  // Edit degree
  const handleEdit = (deg) => {
    setForm({
      degree_id: deg.degree_id,
      degree_name: deg.degree_name,
      duration: deg.duration,
    });
    setEditingId(deg.id);
  };

  // Delete degree
  const handleDelete = (id) => {
    setDegrees(degrees.filter((d) => d.id !== id));
  };

  return (
    <div>
      <h3>Degrees Module</h3>

      {/* FORM */}
      <Form onSubmit={handleSubmit} className="mb-4">
        <Form.Group className="mb-2">
          <Form.Label>Degree ID</Form.Label>
          <Form.Control
            name="degree_id"
            value={form.degree_id}
            onChange={handleChange}
            required
          />
        </Form.Group>

        <Form.Group className="mb-2">
          <Form.Label>Degree Name</Form.Label>
          <Form.Control
            name="degree_name"
            value={form.degree_name}
            onChange={handleChange}
            required
          />
        </Form.Group>

        <Form.Group className="mb-2">
          <Form.Label>Duration (years)</Form.Label>
          <Form.Control
            name="duration"
            value={form.duration}
            onChange={handleChange}
            required
          />
        </Form.Group>

        <Button type="submit" variant={editingId ? "warning" : "primary"}>
          {editingId ? "Update Degree" : "Add Degree"}
        </Button>
      </Form>

      {/* TABLE */}
      <Table striped bordered hover>
        <thead>
          <tr>
            <th>Degree ID</th>
            <th>Name</th>
            <th>Duration</th>
            <th>Actions</th>
          </tr>
        </thead>

        <tbody>
          {degrees.length === 0 ? (
            <tr>
              <td colSpan="4" className="text-center">
                No degrees added yet.
              </td>
            </tr>
          ) : (
            degrees.map((d) => (
              <tr key={d.id}>
                <td>{d.degree_id}</td>
                <td>{d.degree_name}</td>
                <td>{d.duration}</td>
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

export default Degrees;
