package net.infinite_labs.basics.test;

import java.util.Arrays;
import java.util.List;
import java.util.Map;

import net.infinite_labs.basics.Contains;
import net.infinite_labs.basics.Optional;
import net.infinite_labs.basics.Schema;
import net.infinite_labs.basics.Schema.ValidationException;

import org.json.JSONArray;
import org.json.JSONObject;
import org.junit.Test;

import static org.junit.Assert.*;
import static org.hamcrest.CoreMatchers.*;


public class SchemaTest {
	interface Empty {}
	
	@Test
	public void testEmptyInterface() throws Exception {
		Empty e = Schema.make(new JSONObject(), Empty.class);
		assertNotNull(e);
	}
	
	
	interface SimpleTypes {
		String stringValue();
		int intValue();
		long longValue();
		boolean boolValue();
		float floatValue();
		double doubleValue();
	}
	
	@Test
	public void testSimpleTypes() throws Exception {
		JSONObject o = new JSONObject();
		o.put("stringValue", "string");
		o.put("intValue", new Integer(42));
		o.put("longValue", new Long(42L));
		o.put("boolValue", Boolean.TRUE);
		o.put("floatValue", new Float(42.23f));
		o.put("doubleValue", new Double(42.23));
		
		SimpleTypes t = Schema.make(o, SimpleTypes.class);
		assertNotNull(t);
		
		assertEquals(t.stringValue(), "string");
		assertEquals(t.intValue(), 42);
		assertEquals(t.longValue(), 42);
		assertEquals(t.boolValue(), true);
		assertThat(t.floatValue(), is(42.23f));
		assertThat(t.doubleValue(), is(42.23));
	}
	
	interface OptionalFields {
		@Optional String mayNotBeThereString();
		@Optional(defaultLong = 23) long mayNotBeThereLong();
		
		String requiredString();
	}
	
	@Test
	public void testOptionalFields() throws Exception {
		String testString = "testString";
		
		JSONObject stuff = new JSONObject();
		stuff.put("mayNotBeThereString", testString);
		stuff.put("mayNotBeThereLong", new Long(42));
		stuff.put("requiredString", testString);
		
		Exception e = null;
		try {
			Schema.make(new JSONObject(), OptionalFields.class);
		} catch (Exception ex) {
			e = ex;
		}
		
		assertNotNull(e); 
		
		JSONObject bareMinimum = new JSONObject();
		bareMinimum.put("requiredString", testString);
		
		OptionalFields without = Schema.make(bareMinimum, OptionalFields.class);
		OptionalFields with = Schema.make(stuff, OptionalFields.class);
		
		assertThat(without.mayNotBeThereString(), is((String) null));
		assertThat(with.mayNotBeThereString(), is(testString));
		
		assertThat(without.mayNotBeThereLong(), is(23L));
		assertThat(with.mayNotBeThereLong(), is(42L));
		
		assertThat(with.requiredString(), is(testString));
		assertThat(without.requiredString(), is(testString));
	}
	
	interface ArrayFields {
		@Contains(String.class)
		List<String> fruit(); 
	}
	
	@Test
	public void testArrayFields() throws Exception {
		JSONArray a = new JSONArray();
		a.put("pear");
		a.put("orange");
		a.put("apple");
		
		JSONObject o = new JSONObject();
		o.put("fruit", a);
		
		ArrayFields f = Schema.make(o, ArrayFields.class);
		
		assertThat(f.fruit().size(), is(3));
		assertThat(f.fruit().get(0), is("pear"));
		assertThat(f.fruit().get(1), is("orange"));
		assertThat(f.fruit().get(2), is("apple"));
	}
	
	@Test
	public void testArrayFieldsWithInvalidContentType() throws Exception {
		JSONArray a = new JSONArray();
		a.put(1);
		
		JSONObject o = new JSONObject();
		o.put("fruit", a);
		
		Exception ex = null;
		try {
			Schema.make(o, ArrayFields.class);
		} catch (ValidationException e) {
			ex = e;
		}
		
		assertNotNull(ex);
	}
	
	interface MapFields {
		@Contains(Integer.class)
		Map<String, Integer> fruitRatings();
	}
	
	@Test
	public void testMapFields() throws Exception {
		JSONObject a = new JSONObject();
		a.put("pear", 2);
		a.put("orange", 1);
		a.put("apple", 9001);
		
		JSONObject o = new JSONObject();
		o.put("fruitRatings", a);
		
		MapFields f = Schema.make(o, MapFields.class);
		
		assertThat(f.fruitRatings().size(), is(3));
		assertThat(f.fruitRatings().get("pear"), is(new Integer(2)));
		assertThat(f.fruitRatings().get("orange"), is(new Integer(1)));
		assertThat(f.fruitRatings().get("apple"), is(new Integer(9001)));
	}
	
	@Test
	public void testMapFieldsWithInvalidContentType() throws Exception {
		JSONObject a = new JSONObject();
		a.put("pear", "somewhat");
		
		JSONObject o = new JSONObject();
		o.put("fruitRatings", a);

		Exception ex = null;
		try {
			Schema.make(o, MapFields.class);
		} catch (ValidationException e) {
			ex = e;
		}
		
		assertNotNull(ex);
	}
	
	interface Fruit {
		String name();
	}
	
	interface OneFruitBox {
		Fruit fruit();
	}
	
	@Test
	public void testEmbeddedSchemas() throws Exception {
		JSONObject pear = new JSONObject();
		pear.put("name", "pear");
		
		JSONObject fruitBox = new JSONObject();
		fruitBox.put("fruit", pear);
		
		OneFruitBox box = Schema.make(fruitBox, OneFruitBox.class);
		assertNotNull(box);
		assertNotNull(box.fruit());
		
		assertThat(box.fruit().name(), is("pear"));
	}
	
	interface ShoppingBagOfFruit {
		@Contains(Fruit.class) List<Fruit> allFruit();
	}
	
	@Test
	public void testArraysOfEmbeddedSchemas() throws Exception {
		JSONObject pear = new JSONObject();
		pear.put("name", "pear");
		
		JSONObject apple = new JSONObject();
		apple.put("name", "apple");
		
		JSONObject shoppingBag = new JSONObject();
		shoppingBag.put("allFruit", new JSONArray(Arrays.asList(pear, apple)));
		
		ShoppingBagOfFruit bag = Schema.make(shoppingBag, ShoppingBagOfFruit.class);
		assertNotNull(bag);
		assertNotNull(bag.allFruit());
		
		assertThat(bag.allFruit().size(), is(2));
		assertThat(bag.allFruit().get(0).name(), is("pear"));
		assertThat(bag.allFruit().get(1).name(), is("apple"));
	}
	
	interface OwnedFruitsShelf {
		@Contains(Fruit.class) Map<String, Fruit> fruitByOwner();
	}
	
	@Test
	public void testMapsOfEmbeddedSchemas() throws Exception {
		JSONObject pear = new JSONObject();
		pear.put("name", "pear");
		
		JSONObject apple = new JSONObject();
		apple.put("name", "apple");
		
		JSONObject owners = new JSONObject();
		owners.put("John", pear);
		owners.put("Jack", apple);
		
		JSONObject shelfMap = new JSONObject();
		shelfMap.put("fruitByOwner", owners);
		
		OwnedFruitsShelf shelf = Schema.make(shelfMap, OwnedFruitsShelf.class);
		assertNotNull(shelf);
		assertNotNull(shelf.fruitByOwner());
		
		assertThat(shelf.fruitByOwner().size(), is(2));
		assertThat(shelf.fruitByOwner().get("John").name(), is("pear"));
		assertThat(shelf.fruitByOwner().get("Jack").name(), is("apple"));
	}
}
