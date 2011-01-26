package net.infinite_labs.basics;

import java.util.List;
import java.io.UnsupportedEncodingException;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class Schema {
	public static class ValidationException extends Exception {
		private static final long serialVersionUID = 2570962632826686237L;

		public ValidationException(String whatHappened) {
			super(whatHappened);
		}

		public ValidationException() {
			super();
		}

		public ValidationException(String message, Throwable cause) {
			super(message, cause);
		}

		public ValidationException(Throwable cause) {
			super(cause);
		}
		
	}

	public static class InvalidAnnotationsException extends RuntimeException {
		private static final long serialVersionUID = 2570962632826686237L;

		public InvalidAnnotationsException(String whatHappened) {
			super(whatHappened);
		}
	}
	
	private static Class<?> boxedClassForClass(Class<?> c) {
		if (c == int.class)
			return Integer.class;
		else if (c == long.class)
			return Long.class;
		else if (c == boolean.class)
			return Boolean.class;
		else if (c == float.class)
			return Float.class;
		else if (c == double.class)
			return Double.class;
		else
			return c;
	}
	
	private final static Object Null = new Object();
	
	private static Object defaultObjectForOptionalAnnotationAndType(Class<?> c, Optional annotation) {
		if (c == int.class)
			return annotation.defaultInt();
		else if (c == long.class)
			return annotation.defaultLong();
		else if (c == boolean.class)
			return annotation.defaultBoolean();
		else if (c == float.class)
			return annotation.defaultFloat();
		else if (c == double.class)
			return annotation.defaultDouble();
		else if (annotation.defaultIsNull())
			return Null;
		else if (c == String.class)
			return annotation.defaultString();
		else
			throw new InvalidAnnotationsException("Interface has an optional annotation that's contradictory -- what value should I use?");
	}
	
	private static boolean isObjectOfExpectedType(Object x, Class<?> cls) {
		return boxedClassForClass(cls).isInstance(x);
	}
	
	@SuppressWarnings("unchecked")
	public static <T> T make(Object source, Class<T> interf) throws ValidationException {
		if (source instanceof byte[]) {
			try {
				source = new String((byte[]) source, "UTF-8");
			} catch (UnsupportedEncodingException e) {
				throw new RuntimeException(e);
			}
		}
		
		if (source instanceof String) {
			try {
				source = new JSONObject((String) source);
			} catch (JSONException e) {
				throw new ValidationException("The value passed in seems not to be valid JSON.", e);
			}
		}
		
		if (!(source instanceof JSONObject))
			throw new ValidationException("The value passed in isn't a JSON object (or convertible to).");
		
		final JSONObject o = (JSONObject) source;
		final HashMap<String, Object> values = new HashMap<String, Object>();
		
		for (Method m : interf.getMethods()) {
			
			String fieldName = m.getName(); // TODO differing field names
			
			Class<?> expectedType = m.getReturnType();
			
			Optional optionalNote = m.getAnnotation(Optional.class);
			boolean isRequired = (optionalNote == null);
			boolean hasValue = o.has(fieldName);
			if (isRequired && !hasValue)
				throw new IllegalArgumentException(); // TODO
			else if (!isRequired && !hasValue) {
				values.put(fieldName, defaultObjectForOptionalAnnotationAndType(expectedType, optionalNote));
				continue;
			}
			
			Object x = o.opt(fieldName); // we know it will never return null.
			
			if (expectedType == Map.class) {
				
				if (!(x instanceof JSONObject))
					throw new ValidationException("Key " + fieldName + " has a value " + x + " of invalid value (expected a JSON object (map).)");
				
				JSONObject xJSON = (JSONObject) x;
				Iterator<String> i = xJSON.keys();
				
				Contains containsNote = m.getAnnotation(Contains.class);
				
				HashMap<String, Object> finalMap = new HashMap<String, Object>();
				while (i.hasNext()) {
					String s = (String) i.next();
					Object y = xJSON.opt(s); // we know it will never return null.
					
					if (containsNote != null) {
						if (!isObjectOfExpectedType(y, containsNote.value()))
							throw new ValidationException("Map of key " + fieldName + " contains a value " + x + " which is not of the @Contains-mandated type " + containsNote.value());
					}
					
					finalMap.put(s, y); 
				}
				
				values.put(fieldName, finalMap);
				
			} else if (expectedType == List.class) {
				
				if (!(x instanceof JSONArray))
					throw new ValidationException("Key " + fieldName + " has a value " + x + " of invalid value (expected a JSON array.)");
				
				JSONArray xJSON = (JSONArray) x;
				
				Contains containsNote = m.getAnnotation(Contains.class);
				
				ArrayList<Object> finalList = new ArrayList<Object>();
				for (int i = 0; i < xJSON.length(); i++) {
					Object y = xJSON.opt(i); // we know it will never return null.
					
					if (containsNote != null) {
						if (!isObjectOfExpectedType(y, containsNote.value()))
							throw new ValidationException("Array of key " + fieldName + " contains a value " + x + " which is not of the @Contains-mandated type " + containsNote.value());
					}
					
					finalList.add(y);
				}
				
				values.put(fieldName, finalList);
				
			} else {
				if (!isObjectOfExpectedType(x, expectedType))
					throw new ValidationException("Key " + fieldName + " has a value " + x + " of invalid type (expected: " + expectedType + ")");

				values.put(fieldName, x);
			}
			
		}
		
		return (T) Proxy.newProxyInstance(interf.getClassLoader(), new Class<?>[] { interf }, new InvocationHandler() {
			
			@Override
			public Object invoke(Object self, Method method, Object[] args)
					throws Throwable {
				
				String name = method.getName();
				Object returnValue = values.get(name);
				
				if (returnValue == Null)
					returnValue = null;
				
				return returnValue;
				
			}
		});
	}
}
